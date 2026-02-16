//
//  AppStoreConnectModels.swift
//  PriceWizard
//
//  Codable models for App Store Connect API JSON:API responses.
//

import Foundation

// MARK: - JSON:API Document

struct JSONAPIDocument<T: Codable>: Codable {
    let data: T
    let included: [JSONAPIResource]?
    let links: PagedDocumentLinks?
}

struct JSONAPIResource: Codable {
    let type: String
    let id: String
    let attributes: [String: AnyCodable]?
    let relationships: [String: AnyCodable]?

    enum CodingKeys: String, CodingKey {
        case type, id, attributes, relationships
    }

    func decodeAttributes<T: Decodable>(as type: T.Type) throws -> T? {
        guard let attributes else { return nil }
        let data = try JSONEncoder().encode(attributes)
        return try? JSONDecoder().decode(T.self, from: data)
    }
}

struct PagedDocumentLinks: Codable {
    let next: String?
}

struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let bool = try? container.decode(Bool.self) { value = bool }
        else if let int = try? container.decode(Int.self) { value = int }
        else if let double = try? container.decode(Double.self) { value = double }
        else if let string = try? container.decode(String.self) { value = string }
        else if let array = try? container.decode([AnyCodable].self) { value = array.map { $0.value } }
        else if let dict = try? container.decode([String: AnyCodable].self) { value = dict.mapValues { $0.value } }
        else { value = NSNull() }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let v as Bool: try container.encode(v)
        case let v as Int: try container.encode(v)
        case let v as Double: try container.encode(v)
        case let v as String: try container.encode(v)
        case let v as [Any]: try container.encode(v.map { AnyCodable($0) })
        case let v as [String: Any]: try container.encode(v.mapValues { AnyCodable($0) })
        default: try container.encodeNil()
        }
    }
}

// MARK: - Apps

struct AppsResponse: Codable {
    let data: [AppResource]
    let included: [JSONAPIResource]?
    let links: PagedDocumentLinks?
}

struct AppResource: Codable, Hashable {
    let type: String
    let id: String
    let attributes: AppAttributes

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: AppResource, rhs: AppResource) -> Bool { lhs.id == rhs.id }

    struct AppAttributes: Codable {
        let name: String?
        let bundleId: String?
        let sku: String?
    }
}

// MARK: - Subscription Groups

struct SubscriptionGroupsResponse: Codable {
    let data: [SubscriptionGroupResource]
    let included: [JSONAPIResource]?
    let links: PagedDocumentLinks?
}

struct SubscriptionGroupResource: Codable {
    let type: String
    let id: String
    let attributes: SubscriptionGroupAttributes

    struct SubscriptionGroupAttributes: Codable {
        let referenceName: String?
    }
}

// MARK: - Subscriptions

struct SubscriptionsResponse: Codable {
    let data: [SubscriptionResource]
    let included: [JSONAPIResource]?
    let links: PagedDocumentLinks?
}

struct SubscriptionResource: Codable, Hashable {
    let type: String
    let id: String
    let attributes: SubscriptionAttributes

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: SubscriptionResource, rhs: SubscriptionResource) -> Bool { lhs.id == rhs.id }

    struct SubscriptionAttributes: Codable {
        let name: String?
        let productId: String?
        let state: String?
        let subscriptionPeriod: String?
        let groupLevel: Int?
    }
}

// MARK: - Subscription Prices

struct SubscriptionPricesResponse: Codable {
    let data: [SubscriptionPriceResource]
    let included: [JSONAPIResource]?
    let links: PagedDocumentLinks?
}

struct SubscriptionPriceResource: Codable {
    let type: String
    let id: String
    let attributes: SubscriptionPriceAttributes?
    let relationships: SubscriptionPriceRelationships?

    struct SubscriptionPriceAttributes: Codable {
        let startDate: String?
        let preserved: Bool?
    }

    struct SubscriptionPriceRelationships: Codable {
        let territory: RelationshipData?
        let subscriptionPricePoint: RelationshipData?
    }
}

extension SubscriptionPricesResponse {
    /// Builds territory ID → current price string from data + included.
    func currentPriceByTerritory() -> [String: String] {
        var pricePointById: [String: String] = [:]
        for resource in included ?? [] where resource.type == "subscriptionPricePoints" {
            if let attrs = try? resource.decodeAttributes(as: SubscriptionPricePointResource.SubscriptionPricePointAttributes.self) {
                pricePointById[resource.id] = attrs.customerPrice ?? "—"
            }
        }
        var result: [String: String] = [:]
        for price in data {
            guard let tid = price.relationships?.territory?.data?.id,
                  let ppId = price.relationships?.subscriptionPricePoint?.data?.id else { continue }
            if let customerPrice = pricePointById[ppId] {
                result[tid] = customerPrice
            }
        }
        return result
    }
}

struct RelationshipData: Codable {
    let data: ResourceIdentifier?
}

struct ResourceIdentifier: Codable {
    let type: String
    let id: String
}

// MARK: - Subscription Price Points

struct SubscriptionPricePointsResponse: Codable {
    let data: [SubscriptionPricePointResource]
    let included: [JSONAPIResource]?
    let links: PagedDocumentLinks?
}

struct SubscriptionPricePointResource: Codable, Hashable {
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: SubscriptionPricePointResource, rhs: SubscriptionPricePointResource) -> Bool { lhs.id == rhs.id }

    let type: String
    let id: String
    let attributes: SubscriptionPricePointAttributes
    let relationships: SubscriptionPricePointRelationships?

    struct SubscriptionPricePointAttributes: Codable {
        let customerPrice: String?
        let proceeds: String?
        let proceedsYear2: String?
    }

    struct SubscriptionPricePointRelationships: Codable {
        let territory: RelationshipData?
    }
}

// MARK: - Equalizations (price points + included territories)

struct EqualizationsResponse: Codable {
    let data: [SubscriptionPricePointResource]
    let included: [TerritoryResource]?
}

// MARK: - Territories

struct TerritoriesResponse: Codable {
    let data: [TerritoryResource]
    let links: PagedDocumentLinks?
}

struct TerritoryResource: Codable {
    let type: String
    let id: String
    let attributes: TerritoryAttributes

    struct TerritoryAttributes: Codable {
        let currency: String?
    }
}

// MARK: - Subscription Price Create Request

struct SubscriptionPriceCreateRequest: Codable {
    let data: DataPayload

    struct DataPayload: Codable {
        let type: String = "subscriptionPrices"
        let attributes: AttributesPayload?
        let relationships: RelationshipsPayload

        struct AttributesPayload: Codable {
            let startDate: String?
            let preserveCurrentPrice: Bool?
        }

        struct RelationshipsPayload: Codable {
            let subscription: RelationshipData
            let subscriptionPricePoint: RelationshipData
            let territory: RelationshipData?
        }
    }
}
