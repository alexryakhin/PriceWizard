//
//  TerritoryIndices.swift
//  PriceWizard
//
//  Preset pricing indices by territory. Multiplier applied to base (US) price.
//  Based on Netflix and Spotify global pricing patterns.
//

import Foundation

enum TerritoryIndices {
    /// Netflix-style: aggressive localization – large discounts in emerging markets,
    /// premium pricing in high-income regions (e.g. Switzerland, Nordic).
    static let netflix: [String: Double] = [
        "USA": 1.0, "US": 1.0, "GBR": 1.0, "GB": 1.0, "CAN": 0.95, "AUS": 1.0,
        "DEU": 1.0, "FRA": 1.0, "JPN": 0.95, "CHE": 1.2, "NLD": 1.0, "BEL": 1.0,
        "AUT": 1.0, "SWE": 1.05, "NOR": 1.1, "DNK": 1.05, "FIN": 1.0, "IRL": 1.0,
        "ESP": 0.9, "ITA": 0.95, "PRT": 0.85, "GRC": 0.8, "POL": 0.7, "CZE": 0.7,
        "HUN": 0.65, "ROU": 0.6, "BGR": 0.55, "HRV": 0.65, "SVK": 0.65, "SVN": 0.7,
        "IND": 0.25, "PAK": 0.2, "BGD": 0.22, "LKA": 0.35, "IDN": 0.35, "THA": 0.45,
        "VNM": 0.4, "PHL": 0.4, "MYS": 0.5, "SGP": 0.85, "KOR": 0.9, "TWN": 0.75,
        "CHN": 0.6, "HKG": 0.9, "MEX": 0.5, "BRA": 0.45, "ARG": 0.5, "COL": 0.45,
        "CHL": 0.55, "PER": 0.45, "COD": 0.25, "COG": 0.4, "EGY": 0.25, "ZAF": 0.5, "NGA": 0.3, "KEN": 0.35,
        "MAR": 0.4, "TUR": 0.4, "ISR": 0.85, "ARE": 0.75, "SAU": 0.7, "RUS": 0.5,
        "UKR": 0.45, "NZL": 0.95, "LUX": 1.05, "ISL": 1.1,
        "ALB": 0.5, "ARM": 0.5, "AZE": 0.45, "BLR": 0.45, "BIH": 0.55, "GEO": 0.5,
        "MKD": 0.5, "MDA": 0.5, "MNE": 0.55, "SRB": 0.55, "XKS": 0.45, "EST": 0.75, "LVA": 0.7,
        "LTU": 0.7, "AGO": 0.4, "BWA": 0.5, "GHA": 0.35, "TZA": 0.35, "UGA": 0.35,
        "JAM": 0.5, "TTO": 0.55, "CRI": 0.5, "PAN": 0.5, "ECU": 0.45, "URY": 0.55,
        "BOL": 0.4, "PRY": 0.4, "DOM": 0.45, "GTM": 0.4, "HND": 0.4, "SLV": 0.4,
        "NIC": 0.4, "VEN": 0.4, "TUN": 0.45, "DZA": 0.4, "LBN": 0.5, "JOR": 0.5,
        "QAT": 0.8, "KWT": 0.75, "BHR": 0.75, "OMN": 0.7, "KAZ": 0.5, "UZB": 0.45
    ]

    /// Spotify-style: moderate localization – similar to Netflix but slightly less variance.
    static let spotify: [String: Double] = [
        "USA": 1.0, "US": 1.0, "GBR": 1.0, "GB": 1.0, "CAN": 0.95, "AUS": 1.0,
        "DEU": 0.95, "FRA": 0.95, "JPN": 0.9, "CHE": 1.15, "NLD": 0.95, "BEL": 0.95,
        "AUT": 0.95, "SWE": 1.0, "NOR": 1.05, "DNK": 1.0, "FIN": 0.95, "IRL": 0.95,
        "ESP": 0.85, "ITA": 0.9, "PRT": 0.8, "GRC": 0.75, "POL": 0.65, "CZE": 0.65,
        "HUN": 0.6, "ROU": 0.55, "BGR": 0.5, "HRV": 0.6, "SVK": 0.6, "SVN": 0.65,
        "IND": 0.2, "PAK": 0.15, "BGD": 0.18, "LKA": 0.3, "IDN": 0.3, "THA": 0.4,
        "VNM": 0.35, "PHL": 0.35, "MYS": 0.45, "SGP": 0.8, "KOR": 0.85, "TWN": 0.7,
        "CHN": 0.55, "HKG": 0.85, "MEX": 0.45, "BRA": 0.4, "ARG": 0.45, "COL": 0.4,
        "CHL": 0.5, "PER": 0.4, "COD": 0.2, "COG": 0.35, "EGY": 0.2, "ZAF": 0.45, "NGA": 0.15, "KEN": 0.3,
        "MAR": 0.35, "TUR": 0.2, "ISR": 0.8, "ARE": 0.7, "SAU": 0.65, "RUS": 0.45,
        "UKR": 0.4, "NZL": 0.9, "LUX": 1.0, "ISL": 1.05,
        "ALB": 0.45, "ARM": 0.45, "AZE": 0.4, "BLR": 0.4, "BIH": 0.5, "GEO": 0.45,
        "MKD": 0.45, "MDA": 0.45, "MNE": 0.5, "SRB": 0.5, "XKS": 0.4, "EST": 0.7, "LVA": 0.65,
        "LTU": 0.65, "AGO": 0.35, "BWA": 0.45, "GHA": 0.3, "TZA": 0.3, "UGA": 0.3,
        "JAM": 0.45, "TTO": 0.5, "CRI": 0.45, "PAN": 0.45, "ECU": 0.4, "URY": 0.5,
        "BOL": 0.35, "PRY": 0.35, "DOM": 0.4, "GTM": 0.35, "HND": 0.35, "SLV": 0.35,
        "NIC": 0.35, "VEN": 0.35, "TUN": 0.4, "DZA": 0.35, "LBN": 0.45, "JOR": 0.45,
        "QAT": 0.75, "KWT": 0.7, "BHR": 0.7, "OMN": 0.65, "KAZ": 0.45, "UZB": 0.4
    ]

    static func indices(for preset: IndexPreset) -> [String: Double] {
        switch preset {
        case .netflix: return netflix
        case .spotify: return spotify
        }
    }

    static func index(for territoryCode: String, preset: IndexPreset) -> Double {
        indices(for: preset)[territoryCode] ?? 1.0
    }
}

enum IndexPreset: String, CaseIterable {
    case netflix = "Netflix"
    case spotify = "Spotify"
}
