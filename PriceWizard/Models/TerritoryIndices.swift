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
        "QAT": 0.8, "KWT": 0.75, "BHR": 0.75, "OMN": 0.7, "KAZ": 0.5, "UZB": 0.45,
        "AFG": 0.25, "ASM": 0.7, "AND": 0.9, "AIA": 0.7, "ATG": 0.5, "ABW": 0.7,
        "BHS": 0.85, "BLZ": 0.5, "BEN": 0.25, "BMU": 0.95, "BTN": 0.35, "BES": 0.5,
        "VGB": 0.7, "BRN": 0.8, "BFA": 0.2, "BDI": 0.2, "CPV": 0.5, "KHM": 0.35,
        "CMR": 0.35, "CYM": 0.9, "CAF": 0.2, "TCD": 0.25, "COM": 0.35, "CUB": 0.3,
        "CUW": 0.7, "CYP": 0.85, "DJI": 0.4, "DMA": 0.5, "GNQ": 0.45, "ERI": 0.25,
        "SWZ": 0.35, "ETH": 0.25, "FLK": 0.8, "FRO": 0.85, "FJI": 0.55, "GUF": 0.6,
        "PYF": 0.7, "GAB": 0.5, "GMB": 0.25, "GIB": 0.9, "GRL": 0.9, "GRD": 0.5,
        "GLP": 0.7, "GUM": 0.9, "GGY": 0.95, "GIN": 0.25, "GNB": 0.2, "GUY": 0.45,
        "HTI": 0.25, "IMN": 0.95, "IRN": 0.4, "IRQ": 0.4, "JEY": 0.95, "KIR": 0.45,
        "PRK": 0.35, "KGZ": 0.4, "LAO": 0.35, "LSO": 0.35, "LBR": 0.25, "LBY": 0.5,
        "LIE": 1.0, "MAC": 0.9, "MDG": 0.3, "MWI": 0.25, "MDV": 0.55, "MLI": 0.25,
        "MHL": 0.5, "MTQ": 0.7, "MRT": 0.3, "MUS": 0.55, "MYT": 0.6, "FSM": 0.45,
        "MCO": 1.0, "MNG": 0.45, "MSR": 0.6, "MOZ": 0.3, "MMR": 0.3, "NAM": 0.45,
        "NRU": 0.6, "NPL": 0.3, "NCL": 0.75, "NER": 0.2, "NIU": 0.6, "MNP": 0.85,
        "PLW": 0.6, "PSE": 0.5, "PNG": 0.4, "PCN": 0.6, "PRI": 0.85, "REU": 0.8,
        "RWA": 0.3, "BLM": 0.9, "SHN": 0.6, "KNA": 0.6, "LCA": 0.55, "MAF": 0.75,
        "SPM": 0.75, "VCT": 0.5, "WSM": 0.5, "SMR": 0.9, "STP": 0.4, "SEN": 0.35,
        "SYC": 0.6, "SLE": 0.25, "SXM": 0.7, "SLB": 0.4, "SOM": 0.25, "SSD": 0.25,
        "SDN": 0.3, "SUR": 0.5, "SYR": 0.4, "TJK": 0.4, "TLS": 0.35, "TGO": 0.3,
        "TKL": 0.6, "TON": 0.5, "UMI": 1.0, "VIR": 0.85, "VUT": 0.5, "VAT": 0.9,
        "WLF": 0.6, "ESH": 0.4, "YEM": 0.35, "ZMB": 0.3, "ZWE": 0.25
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
        "QAT": 0.75, "KWT": 0.7, "BHR": 0.7, "OMN": 0.65, "KAZ": 0.45, "UZB": 0.4,
        "AFG": 0.2, "ASM": 0.65, "AND": 0.85, "AIA": 0.65, "ATG": 0.45, "ABW": 0.65,
        "BHS": 0.8, "BLZ": 0.45, "BEN": 0.2, "BMU": 0.9, "BTN": 0.3, "BES": 0.45,
        "VGB": 0.65, "BRN": 0.75, "BFA": 0.15, "BDI": 0.15, "CPV": 0.45, "KHM": 0.3,
        "CMR": 0.3, "CYM": 0.85, "CAF": 0.15, "TCD": 0.2, "COM": 0.3, "CUB": 0.25,
        "CUW": 0.65, "CYP": 0.8, "DJI": 0.35, "DMA": 0.45, "GNQ": 0.4, "ERI": 0.2,
        "SWZ": 0.3, "ETH": 0.2, "FLK": 0.75, "FRO": 0.8, "FJI": 0.5, "GUF": 0.55,
        "PYF": 0.65, "GAB": 0.45, "GMB": 0.2, "GIB": 0.85, "GRL": 0.85, "GRD": 0.45,
        "GLP": 0.65, "GUM": 0.85, "GGY": 0.9, "GIN": 0.2, "GNB": 0.15, "GUY": 0.4,
        "HTI": 0.2, "IMN": 0.9, "IRN": 0.35, "IRQ": 0.35, "JEY": 0.9, "KIR": 0.4,
        "PRK": 0.3, "KGZ": 0.35, "LAO": 0.3, "LSO": 0.3, "LBR": 0.2, "LBY": 0.45,
        "LIE": 0.95, "MAC": 0.85, "MDG": 0.25, "MWI": 0.2, "MDV": 0.5, "MLI": 0.2,
        "MHL": 0.45, "MTQ": 0.65, "MRT": 0.25, "MUS": 0.5, "MYT": 0.55, "FSM": 0.4,
        "MCO": 0.95, "MNG": 0.4, "MSR": 0.55, "MOZ": 0.25, "MMR": 0.25, "NAM": 0.4,
        "NRU": 0.55, "NPL": 0.25, "NCL": 0.7, "NER": 0.15, "NIU": 0.55, "MNP": 0.8,
        "PLW": 0.55, "PSE": 0.45, "PNG": 0.35, "PCN": 0.55, "PRI": 0.8, "REU": 0.75,
        "RWA": 0.25, "BLM": 0.85, "SHN": 0.55, "KNA": 0.55, "LCA": 0.5, "MAF": 0.7,
        "SPM": 0.7, "VCT": 0.45, "WSM": 0.45, "SMR": 0.85, "STP": 0.35, "SEN": 0.3,
        "SYC": 0.55, "SLE": 0.2, "SXM": 0.65, "SLB": 0.35, "SOM": 0.2, "SSD": 0.2,
        "SDN": 0.25, "SUR": 0.45, "SYR": 0.35, "TJK": 0.35, "TLS": 0.3, "TGO": 0.25,
        "TKL": 0.55, "TON": 0.45, "UMI": 0.95, "VIR": 0.8, "VUT": 0.45, "VAT": 0.85,
        "WLF": 0.55, "ESH": 0.35, "YEM": 0.3, "ZMB": 0.25, "ZWE": 0.2
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
