//
//  MockAppStoreConnectAPI.swift
//  PriceWizard
//
//  Returns fixture data so users can explore the UI without App Store Connect API access.
//

import Foundation

private let demoAppId = "demo-app-1"
private let demoGroupId = "demo-group-1"
private let demoSubMonthlyId = "demo-sub-monthly"
private let demoSubYearlyId = "demo-sub-yearly"

/// Simulated network latency so demo mode feels realistic (seconds).
private let mockNetworkDelay: UInt64 = 200_000_000 // 0.2s in nanoseconds

final class MockAppStoreConnectAPI: AppStoreConnectAPIProtocol {
    private var cachedUSPricePoints: [SubscriptionPricePointResource]?
    private var cachedTerritories: [TerritoryResource]?

    init() {}

    func clearAllCaches() {}
    func clearSubscriptionPricePointsCache() {
        cachedUSPricePoints = nil
    }

    func getApps(limit: Int = 200, ignoreCache: Bool = false) async throws -> [AppResource] {
        try await Task.sleep(nanoseconds: mockNetworkDelay)
        let response: AppsResponse = try Bundle.main.decode("apps")
        return response.data
    }

    func getSubscriptionGroups(appId: String, limit: Int = 200) async throws -> [SubscriptionGroupResource] {
        try await Task.sleep(nanoseconds: mockNetworkDelay)
        guard appId == demoAppId else { return [] }
        let response: SubscriptionGroupsResponse = try Bundle.main.decode("subscriptionGroups")
        return response.data
    }

    func getSubscriptions(groupId: String, limit: Int = 200) async throws -> [SubscriptionResource] {
        try await Task.sleep(nanoseconds: mockNetworkDelay)
        guard groupId == demoGroupId else { return [] }
        let response: SubscriptionsResponse = try Bundle.main.decode("subscriptions")
        return response.data
    }

    func getSubscriptionPrices(subscriptionId: String, limit: Int = 200) async throws -> [SubscriptionPriceResource] {
        let response = try await getSubscriptionPricesResponse(subscriptionId: subscriptionId, limit: limit)
        return response.data
    }

    func getSubscriptionPricesResponse(subscriptionId: String, limit: Int = 200) async throws -> SubscriptionPricesResponse {
        try await Task.sleep(nanoseconds: mockNetworkDelay)
        guard subscriptionId == demoSubMonthlyId || subscriptionId == demoSubYearlyId else {
            return SubscriptionPricesResponse(data: [], included: nil, links: nil)
        }
        return try Bundle.main.decode("subscriptionPrices")
    }

    func getSubscriptionPricePoints(subscriptionId: String, territoryId: String?, limit: Int) async throws -> [SubscriptionPricePointResource] {
        try await Task.sleep(nanoseconds: mockNetworkDelay)
        guard subscriptionId == demoSubMonthlyId || subscriptionId == demoSubYearlyId,
              territoryId == "USA" || territoryId == "US" else {
            return []
        }
        let response: SubscriptionPricePointsResponse = try Bundle.main.decode("subscriptionPricePointsUSA")
        return response.data
    }

    func getPricePointEqualizations(pricePointId: String, limit: Int = 200) async throws -> (pricePoints: [SubscriptionPricePointResource], territories: [TerritoryResource]) {
        try await Task.sleep(nanoseconds: mockNetworkDelay)
        let usPoints = try await getCachedUSPricePoints()
        let territories = try await getCachedTerritories()
        guard let basePriceStr = usPoints.first(where: { $0.id == pricePointId })?.attributes.customerPrice,
              let baseUSD = Double(basePriceStr.replacingOccurrences(of: ",", with: ".")) else {
            return ([], [])
        }
        let rates = await ExchangeRateService.fetchRatesFromUSD()
        var data: [SubscriptionPricePointResource] = []
        let safeId = pricePointId.replacingOccurrences(of: ":", with: "-").replacingOccurrences(of: ".", with: "-")
        let noDecimals: Set<String> = ["JPY", "KRW", "IDR", "VND", "CLP", "COP", "PKR", "NGN", "BDT", "LKR", "TZS", "RUB", "UAH", "KZT", "HUF"]
        for t in territories {
            let currency = (t.attributes.currency ?? "USD").uppercased()
            let rate = rates[currency] ?? 1.0
            let localAmount = baseUSD * rate
            let priceStr = (noDecimals.contains(currency) || rate >= 100)
                ? String(format: "%.0f", localAmount)
                : String(format: "%.2f", localAmount)
            let eqId = "demo-eq-\(t.id)-\(safeId)"
            let attrs = SubscriptionPricePointResource.SubscriptionPricePointAttributes(customerPrice: priceStr, proceeds: nil, proceedsYear2: nil)
            let rel = SubscriptionPricePointResource.SubscriptionPricePointRelationships(
                territory: RelationshipData(data: ResourceIdentifier(type: "territories", id: t.id))
            )
            data.append(SubscriptionPricePointResource(type: "subscriptionPricePoints", id: eqId, attributes: attrs, relationships: rel))
        }
        return (data, territories)
    }

    func getTerritories(limit: Int = 200) async throws -> [TerritoryResource] {
        try await Task.sleep(nanoseconds: mockNetworkDelay)
        return try await getCachedTerritories()
    }

    private func getCachedTerritories() async throws -> [TerritoryResource] {
        if let cached = cachedTerritories { return cached }
        let response: TerritoriesResponse = try Bundle.main.decode("territories")
        cachedTerritories = response.data
        return response.data
    }

    private func getCachedUSPricePoints() async throws -> [SubscriptionPricePointResource] {
        if let cached = cachedUSPricePoints { return cached }
        let response: SubscriptionPricePointsResponse = try Bundle.main.decode("subscriptionPricePointsUSA")
        cachedUSPricePoints = response.data
        return response.data
    }

    func createSubscriptionPrice(subscriptionId: String, pricePointId: String, territoryId: String?, startDate: String?, preserveCurrentPrice: Bool?) async throws {
        try await Task.sleep(nanoseconds: mockNetworkDelay)
        // No-op in demo mode
    }

    func deleteSubscriptionPrice(priceId: String) async throws {
        try await Task.sleep(nanoseconds: mockNetworkDelay)
        // No-op in demo mode
    }
}
