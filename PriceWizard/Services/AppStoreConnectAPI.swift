//
//  AppStoreConnectAPI.swift
//  PriceWizard
//
//  HTTP client for App Store Connect API with JWT auth and JSON:API handling.
//

import Foundation

enum APIError: Error {
    case unauthorized
    case notFound
    case rateLimited
    case serverError(Int, String?)
    case decodingError(Error)
}

@Observable
final class AppStoreConnectAPI {
    private let baseURL = URL(string: "https://api.appstoreconnect.apple.com")!
    private var getToken: () throws -> String
    private let session: URLSession
    private let decoder: JSONDecoder

    init(getToken: @escaping () throws -> String) {
        self.getToken = getToken
        self.session = URLSession.shared
        self.decoder = JSONDecoder()
    }

    private func request(path: String, queryItems: [URLQueryItem] = [], method: String = "GET", body: Data? = nil) async throws -> (Data, HTTPURLResponse) {
        let pathStr = path.hasPrefix("/") ? path : "/\(path)"
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.path = pathStr
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        guard let url = components.url else {
            throw APIError.serverError(0, "Invalid URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(try getToken())", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        var lastError: Error?
        for attempt in 0..<3 {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw APIError.serverError(0, "Invalid response")
            }
            if http.statusCode == 429 {
                let retryAfter = Double(http.value(forHTTPHeaderField: "Retry-After") ?? "60") ?? 60
                if attempt < 2 {
                    try await Task.sleep(nanoseconds: UInt64(retryAfter * 1_000_000_000))
                    continue
                }
                throw APIError.rateLimited
            }
            if http.statusCode == 401 {
                throw APIError.unauthorized
            }
            if http.statusCode == 404 {
                throw APIError.notFound
            }
            if http.statusCode >= 400 {
                let message = String(data: data, encoding: .utf8)
                throw APIError.serverError(http.statusCode, message)
            }
            return (data, http)
        }
        throw lastError ?? APIError.serverError(0, "Request failed")
    }

    // MARK: - Apps

    func getApps(limit: Int = 200) async throws -> [AppResource] {
        let queryItems = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "sort", value: "name")
        ]
        let (data, _) = try await request(path: "v1/apps", queryItems: queryItems)
        let response = try decoder.decode(AppsResponse.self, from: data)
        return response.data
    }

    // MARK: - Subscription Groups

    func getSubscriptionGroups(appId: String, limit: Int = 200) async throws -> [SubscriptionGroupResource] {
        let queryItems = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "include", value: "subscriptions")
        ]
        let (data, _) = try await request(path: "v1/apps/\(appId)/subscriptionGroups", queryItems: queryItems)
        let response = try decoder.decode(SubscriptionGroupsResponse.self, from: data)
        return response.data
    }

    // MARK: - Subscriptions

    func getSubscriptions(groupId: String, limit: Int = 200) async throws -> [SubscriptionResource] {
        let queryItems = [URLQueryItem(name: "limit", value: "\(limit)")]
        let (data, _) = try await request(path: "v1/subscriptionGroups/\(groupId)/subscriptions", queryItems: queryItems)
        let response = try decoder.decode(SubscriptionsResponse.self, from: data)
        return response.data
    }

    // MARK: - Subscription Prices

    func getSubscriptionPrices(subscriptionId: String, limit: Int = 200) async throws -> [SubscriptionPriceResource] {
        let queryItems = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "include", value: "subscriptionPricePoint,territory")
        ]
        let (data, _) = try await request(path: "v1/subscriptions/\(subscriptionId)/prices", queryItems: queryItems)
        let response = try decoder.decode(SubscriptionPricesResponse.self, from: data)
        return response.data
    }

    // MARK: - Subscription Price Points

    func getSubscriptionPricePoints(subscriptionId: String, territoryId: String? = nil, limit: Int = 200) async throws -> [SubscriptionPricePointResource] {
        var queryItems = [
            URLQueryItem(name: "limit", value: "\(min(limit, 8000))"),
            URLQueryItem(name: "include", value: "territory")
        ]
        if let tid = territoryId {
            queryItems.append(URLQueryItem(name: "filter[territory]", value: tid))
        }
        let (data, _) = try await request(path: "v1/subscriptions/\(subscriptionId)/pricePoints", queryItems: queryItems)
        let response = try decoder.decode(SubscriptionPricePointsResponse.self, from: data)
        return response.data
    }

    // MARK: - Price Point Equalizations

    func getPricePointEqualizations(pricePointId: String, limit: Int = 200) async throws -> (pricePoints: [SubscriptionPricePointResource], territories: [TerritoryResource]) {
        let queryItems = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "include", value: "territory")
        ]
        let (data, _) = try await request(path: "v1/subscriptionPricePoints/\(pricePointId)/equalizations", queryItems: queryItems)
        let response = try decoder.decode(EqualizationsResponse.self, from: data)
        return (response.data, response.included ?? [])
    }

    // MARK: - Territories

    func getTerritories(limit: Int = 200) async throws -> [TerritoryResource] {
        let queryItems = [URLQueryItem(name: "limit", value: "\(limit)")]
        let (data, _) = try await request(path: "v1/territories", queryItems: queryItems)
        let response = try decoder.decode(TerritoriesResponse.self, from: data)
        return response.data
    }

    // MARK: - Create Subscription Price

    func createSubscriptionPrice(subscriptionId: String, pricePointId: String, territoryId: String? = nil, preserveCurrentPrice: Bool? = nil) async throws {
        let subscriptionRef = RelationshipData(data: ResourceIdentifier(type: "subscriptions", id: subscriptionId))
        let pricePointRef = RelationshipData(data: ResourceIdentifier(type: "subscriptionPricePoints", id: pricePointId))
        let territoryRef: RelationshipData? = territoryId.map { RelationshipData(data: ResourceIdentifier(type: "territories", id: $0)) }
        let relationships = SubscriptionPriceCreateRequest.DataPayload.RelationshipsPayload(
            subscription: subscriptionRef,
            subscriptionPricePoint: pricePointRef,
            territory: territoryRef
        )
        let attributes: SubscriptionPriceCreateRequest.DataPayload.AttributesPayload? = preserveCurrentPrice.map {
            .init(startDate: nil, preserveCurrentPrice: $0)
        }
        let payload = SubscriptionPriceCreateRequest(
            data: .init(attributes: attributes, relationships: relationships)
        )
        let body = try JSONEncoder().encode(payload)
        _ = try await request(path: "v1/subscriptionPrices", method: "POST", body: body)
    }

    // MARK: - Delete Subscription Price

    func deleteSubscriptionPrice(priceId: String) async throws {
        _ = try await request(path: "v1/subscriptionPrices/\(priceId)", method: "DELETE")
    }
}

