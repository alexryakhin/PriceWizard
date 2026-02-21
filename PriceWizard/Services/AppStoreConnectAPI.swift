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

// MARK: - App Store Connect API Error Response (openapi.oas.json ErrorResponse schema)
private struct APIErrorResponse: Decodable {
    let errors: [APIErrorItem]
}

private struct APIErrorItem: Decodable {
    let code: String
    let detail: String
    let status: String
    let title: String
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unauthorized:
            return Loc.Errors.unauthorized
        case .notFound:
            return Loc.Errors.notFound
        case .rateLimited:
            return Loc.Errors.rateLimited
        case .serverError(let statusCode, let body):
            return Self.humanReadableMessage(statusCode: statusCode, body: body)
        case .decodingError(let underlying):
            return Loc.Errors.decodingError(underlying.localizedDescription)
        }
    }

    /// Parses Apple's ErrorResponse (errors[].code, detail, status, title) and returns a user-friendly string.
    private static func humanReadableMessage(statusCode: Int, body: String?) -> String {
        guard let body = body,
              let data = body.data(using: .utf8),
              let response = try? JSONDecoder().decode(APIErrorResponse.self, from: data),
              let first = response.errors.first else {
            return Loc.Errors.serverError(statusCode)
        }
        let detailLower = first.detail.lowercased()
        let titleLower = first.title.lowercased()
        // Map common subscription price / start date errors to a clear message
        if detailLower.contains("start date") || detailLower.contains("startdate") ||
           titleLower.contains("start date") || first.code == "STATE_ERROR" {
            if detailLower.contains("future") || detailLower.contains("today") || detailLower.contains("past") {
                return Loc.Errors.startDateMustBeFuture
            }
        }
        // Prefer detail (usually more specific); fall back to title
        if !first.detail.isEmpty {
            return first.detail
        }
        return first.title.isEmpty ? Loc.Errors.serverError(statusCode) : first.title
    }
}

/// Protocol for the App Store Connect API so the UI can use either the real API or a mock (e.g. demo mode).
protocol AppStoreConnectAPIProtocol: AnyObject {
    func clearAllCaches()
    func clearSubscriptionPricePointsCache()
    func getApps(limit: Int, ignoreCache: Bool) async throws -> [AppResource]
    func getSubscriptionGroups(appId: String, limit: Int) async throws -> [SubscriptionGroupResource]
    func getSubscriptions(groupId: String, limit: Int) async throws -> [SubscriptionResource]
    func getSubscriptionPrices(subscriptionId: String, limit: Int) async throws -> [SubscriptionPriceResource]
    func getSubscriptionPricesResponse(subscriptionId: String, limit: Int) async throws -> SubscriptionPricesResponse
    func getSubscriptionPricePoints(subscriptionId: String, territoryId: String?, limit: Int) async throws -> [SubscriptionPricePointResource]
    func getPricePointEqualizations(pricePointId: String, limit: Int) async throws -> (pricePoints: [SubscriptionPricePointResource], territories: [TerritoryResource])
    func getTerritories(limit: Int) async throws -> [TerritoryResource]
    func createSubscriptionPrice(subscriptionId: String, pricePointId: String, territoryId: String?, startDate: String?, preserveCurrentPrice: Bool?) async throws
    func deleteSubscriptionPrice(priceId: String) async throws
}


@Observable
final class AppStoreConnectAPI: AppStoreConnectAPIProtocol {
    private let baseURL = URL(string: "https://api.appstoreconnect.apple.com")!
    private var getToken: () throws -> String
    private let session: URLSession
    private let urlCache: URLCache
    private let decoder: JSONDecoder
    /// Per–price-point equalizations. Key: pricePointId. Never cleared – monthly and yearly subs have different price point IDs.
    private var equalizationsCache: [String: (pricePoints: [SubscriptionPricePointResource], territories: [TerritoryResource])] = [:]
    /// Per-subscription US price points. Key: subscriptionId. Never cleared – switching monthly ↔ yearly reuses cache.
    private var subscriptionPricePointsCache: [String: [SubscriptionPricePointResource]] = [:]
    /// Per-subscription current prices response. Key: subscriptionId. Never cleared.
    private var subscriptionPricesResponseCache: [String: SubscriptionPricesResponse] = [:]

    init(getToken: @escaping () throws -> String) {
        self.getToken = getToken
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        let urlCache = URLCache(memoryCapacity: 20 * 1024 * 1024, diskCapacity: 50 * 1024 * 1024)
        config.urlCache = urlCache
        self.urlCache = urlCache
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
    }

    /// Clears all in-memory and URL caches. Call when you need fresh data (e.g. new app added).
    func clearAllCaches() {
        equalizationsCache.removeAll()
        subscriptionPricePointsCache.removeAll()
        subscriptionPricesResponseCache.removeAll()
        urlCache.removeAllCachedResponses()
    }

    private func request(path: String, queryItems: [URLQueryItem] = [], method: String = "GET", body: Data? = nil, cachePolicy: URLRequest.CachePolicy? = nil) async throws -> (Data, HTTPURLResponse) {
        let pathStr = path.hasPrefix("/") ? path : "/\(path)"
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.path = pathStr
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        guard let url = components.url else {
            throw APIError.serverError(0, "Invalid URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.cachePolicy = cachePolicy ?? .returnCacheDataElseLoad
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
            // Dump API response when PRICE_WIZARD_DUMP_API=1 (e.g. in Xcode scheme env) to capture real response shapes for fixtures.
            if let body = String(data: data, encoding: .utf8) {
                print("--- PriceWizard API response: \(pathStr) ---")
                print(body)
                print("--- end ---")
            }
            return (data, http)
        }
        throw lastError ?? APIError.serverError(0, "Request failed")
    }

    // MARK: - Apps

    /// - Parameter ignoreCache: If true, bypasses URL cache so newly added apps appear immediately.
    func getApps(limit: Int = 200, ignoreCache: Bool = false) async throws -> [AppResource] {
        let queryItems = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "sort", value: "name")
        ]
        let policy: URLRequest.CachePolicy? = ignoreCache ? .reloadIgnoringLocalCacheData : nil
        let (data, _) = try await request(path: "v1/apps", queryItems: queryItems, cachePolicy: policy)
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
        let response = try await getSubscriptionPricesResponse(subscriptionId: subscriptionId, limit: limit)
        return response.data
    }

    /// Returns full response including `included` price point and territory resources.
    func getSubscriptionPricesResponse(subscriptionId: String, limit: Int = 200) async throws -> SubscriptionPricesResponse {
        if let cached = subscriptionPricesResponseCache[subscriptionId] {
            return cached
        }
        let queryItems = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "include", value: "subscriptionPricePoint,territory")
        ]
        let (data, _) = try await request(path: "v1/subscriptions/\(subscriptionId)/prices", queryItems: queryItems)
        let response = try decoder.decode(SubscriptionPricesResponse.self, from: data)
        subscriptionPricesResponseCache[subscriptionId] = response
        return response
    }

    // MARK: - Subscription Price Points

    /// Clears the subscription price points cache. Call when switching subscriptions to limit memory.
    func clearSubscriptionPricePointsCache() {
        subscriptionPricePointsCache.removeAll()
    }

    func getSubscriptionPricePoints(subscriptionId: String, territoryId: String? = nil, limit: Int = 200) async throws -> [SubscriptionPricePointResource] {
        let cacheKey = territoryId.map { "\(subscriptionId):\($0)" } ?? subscriptionId
        if let cached = subscriptionPricePointsCache[cacheKey] {
            return cached
        }
        var queryItems = [
            URLQueryItem(name: "limit", value: "\(min(limit, 8000))"),
            URLQueryItem(name: "include", value: "territory")
        ]
        if let tid = territoryId {
            queryItems.append(URLQueryItem(name: "filter[territory]", value: tid))
        }
        let (data, _) = try await request(path: "v1/subscriptions/\(subscriptionId)/pricePoints", queryItems: queryItems)
        let response = try decoder.decode(SubscriptionPricePointsResponse.self, from: data)
        subscriptionPricePointsCache[cacheKey] = response.data
        return response.data
    }

    // MARK: - Price Point Equalizations

    func getPricePointEqualizations(pricePointId: String, limit: Int = 200) async throws -> (pricePoints: [SubscriptionPricePointResource], territories: [TerritoryResource]) {
        if let cached = equalizationsCache[pricePointId] {
            return cached
        }
        let queryItems = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "include", value: "territory")
        ]
        let (data, _) = try await request(path: "v1/subscriptionPricePoints/\(pricePointId)/equalizations", queryItems: queryItems)
        let response = try decoder.decode(EqualizationsResponse.self, from: data)
        let result: (pricePoints: [SubscriptionPricePointResource], territories: [TerritoryResource]) = (response.data, response.included ?? [])
        equalizationsCache[pricePointId] = result
        return result
    }

    // MARK: - Territories

    func getTerritories(limit: Int = 200) async throws -> [TerritoryResource] {
        let queryItems = [URLQueryItem(name: "limit", value: "\(limit)")]
        let (data, _) = try await request(path: "v1/territories", queryItems: queryItems)
        let response = try decoder.decode(TerritoriesResponse.self, from: data)
        return response.data
    }

    // MARK: - Create Subscription Price

    func createSubscriptionPrice(
        subscriptionId: String,
        pricePointId: String,
        territoryId: String? = nil,
        startDate: String? = nil,
        preserveCurrentPrice: Bool? = nil
    ) async throws {
        let subscriptionRef = RelationshipData(data: ResourceIdentifier(type: "subscriptions", id: subscriptionId))
        let pricePointRef = RelationshipData(data: ResourceIdentifier(type: "subscriptionPricePoints", id: pricePointId))
        let territoryRef: RelationshipData? = territoryId.map { RelationshipData(data: ResourceIdentifier(type: "territories", id: $0)) }
        let relationships = SubscriptionPriceCreateRequest.DataPayload.RelationshipsPayload(
            subscription: subscriptionRef,
            subscriptionPricePoint: pricePointRef,
            territory: territoryRef
        )
        let attributes: SubscriptionPriceCreateRequest.DataPayload.AttributesPayload? =
            (startDate != nil || preserveCurrentPrice != nil)
                ? .init(startDate: startDate, preserveCurrentPrice: preserveCurrentPrice)
                : nil
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

