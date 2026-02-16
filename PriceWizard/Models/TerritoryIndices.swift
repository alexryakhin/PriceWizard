//
//  TerritoryIndices.swift
//  PriceWizard
//
//  Preset pricing indices by territory. Multiplier applied to base (US) price.
//  Netflix: Beebom Jan 2026 (US $15.49). Spotify: user-provided data (US $11.99).
//

import Foundation

enum TerritoryIndices {
    /// Netflix-style: real multipliers from Beebom Jan 2026 Netflix pricing.
    /// Source: https://beebom.com/how-much-netflix-costs-each-country-worldwide/
    static let netflix: [String: Double] = [
        "USA": 1.0, "US": 1.0, "AFG": 0.52, "ALB": 0.56, "DZA": 0.52, "ASM": 1.0,
        "AND": 0.9, "AGO": 0.52, "AIA": 0.84, "ATG": 0.84, "ARG": 0.3, "ARM": 0.69,
        "ABW": 0.84, "AUS": 0.72, "AUT": 0.9, "AZE": 0.69, "BHS": 0.84, "BHR": 0.68,
        "BGD": 0.52, "BRB": 0.99, "BLR": 0.69, "BEL": 0.94, "BLZ": 0.39, "BEN": 0.84,
        "BMU": 0.84, "BTN": 0.52, "BOL": 0.39, "BES": 0.84, "BIH": 0.56, "BWA": 0.19,
        "BRA": 0.52, "VGB": 0.84, "BRN": 0.77, "BGR": 0.56, "BFA": 0.52, "BDI": 0.52,
        "CPV": 0.52, "KHM": 0.52, "CMR": 0.52, "CAN": 0.78, "CYM": 0.84, "CAF": 0.52,
        "TCD": 0.52, "CHL": 0.62, "CHN": 0.6, "COL": 0.44, "COM": 0.52, "COD": 0.52,
        "COG": 0.52, "CRI": 0.84, "CIV": 0.52, "HRV": 0.56, "CUB": 0.39, "CUW": 0.84,
        "CYP": 0.76, "CZE": 0.74, "DNK": 1.06, "DJI": 0.52, "DMA": 0.39, "DOM": 0.52,
        "ECU": 0.52, "EGY": 0.3, "SLV": 0.52, "GNQ": 0.52, "ERI": 0.52, "EST": 0.69,
        "SWZ": 0.52, "ETH": 0.52, "FLK": 0.84, "FRO": 1.06, "FJI": 0.52, "FIN": 0.83,
        "FRA": 0.94, "GUF": 0.87, "PYF": 0.77, "GAB": 0.52, "GMB": 0.52, "GEO": 0.82,
        "DEU": 0.9, "GHA": 0.52, "GIB": 0.9, "GRC": 0.76, "GRL": 1.06, "GRD": 0.39,
        "GLP": 0.87, "GUM": 1.0, "GGY": 0.89, "GIN": 0.52, "GNB": 0.52, "GUY": 0.39,
        "HTI": 0.39, "HND": 0.52, "HKG": 0.65, "HUN": 0.64, "ISL": 0.9, "IND": 0.39,
        "IDN": 0.5, "IRN": 0.65, "IRQ": 0.52, "IRL": 1.04, "IMN": 0.89, "ISR": 0.82,
        "ITA": 0.9, "JAM": 0.39, "JPN": 0.66, "JEY": 0.89, "JOR": 0.52, "KAZ": 0.69,
        "KEN": 0.3, "KIR": 0.52, "PRK": 0.35, "KOR": 0.66, "KWT": 0.65, "XKS": 0.56,
        "KGZ": 0.69, "LAO": 0.52, "LVA": 0.69, "LBN": 0.52, "LSO": 0.52, "LBR": 0.52,
        "LBY": 0.52, "LIE": 1.39, "LTU": 0.69, "LUX": 0.94, "MAC": 0.65, "MDG": 0.52,
        "MWI": 0.52, "MYS": 0.62, "MDV": 0.77, "MLI": 0.52, "MLT": 0.9, "MHL": 1.0,
        "MTQ": 0.87, "MRT": 0.52, "MUS": 0.52, "MYT": 0.87, "MEX": 0.82, "FSM": 1.0,
        "MDA": 0.69, "MCO": 0.94, "MNG": 0.52, "MNE": 0.56, "MSR": 0.84, "MAR": 0.41,
        "MOZ": 0.52, "MMR": 0.52, "NAM": 0.52, "NRU": 0.77, "NPL": 0.52, "NLD": 0.83,
        "NCL": 0.77, "NZL": 0.73, "NIC": 0.39, "NER": 0.52, "NGA": 0.3, "NIU": 0.73,
        "MKD": 0.56, "MNP": 1.0, "NOR": 0.65, "OMN": 0.68, "PAK": 0.18, "PLW": 1.0,
        "PSE": 0.52, "PAN": 0.58, "PNG": 0.52, "PRY": 0.39, "PER": 0.6, "PHL": 0.46,
        "PCN": 0.19, "POL": 0.69, "PRT": 0.83, "PRI": 1.0, "QAT": 0.65, "REU": 0.81,
        "ROU": 0.69, "RUS": 0.52, "RWA": 0.52, "BLM": 0.39, "SHN": 0.52, "KNA": 0.84,
        "LCA": 0.39, "MAF": 0.39, "SPM": 0.94, "VCT": 0.39, "WSM": 0.52, "SMR": 0.9,
        "STP": 0.52, "SAU": 0.74, "SEN": 0.52, "SRB": 0.56, "SYC": 0.52, "SLE": 0.52,
        "SGP": 0.84, "SXM": 0.84, "SVK": 0.69, "SVN": 0.56, "SLB": 0.52, "SOM": 0.52,
        "ZAF": 0.54, "SSD": 0.52, "ESP": 0.9, "LKA": 0.52, "SDN": 0.52, "SUR": 0.39,
        "SWE": 0.8, "CHE": 1.39, "SYR": 0.52, "TWN": 0.68, "TJK": 0.82, "TZA": 0.52,
        "THA": 0.64, "TLS": 0.52, "TGO": 0.52, "TKL": 0.73, "TON": 0.52, "TTO": 0.84,
        "TUN": 0.52, "TUR": 0.3, "TKM": 0.69, "TCA": 0.84, "TUV": 0.52, "UGA": 0.52,
        "UKR": 0.52, "ARE": 0.69, "GBR": 0.89, "GB": 0.89, "UMI": 0.65, "VIR": 1.0,
        "URY": 0.84, "UZB": 0.69, "VUT": 0.52, "VAT": 0.9, "VEN": 0.39, "VNM": 0.59,
        "WLF": 0.52, "ESH": 0.65, "YEM": 0.52, "ZMB": 0.52, "ZWE": 0.52
    ]

    /// Spotify-style: real multipliers from user-provided data (US base $11.99).
    static let spotify: [String: Double] = [
        "USA": 1.0, "US": 1.0, "GBR": 1.08, "GB": 1.08, "CAN": 1.0, "AUS": 1.13,
        "DEU": 0.95, "FRA": 1.08, "JPN": 0.9, "CHE": 1.37, "NLD": 1.08, "BEL": 1.08,
        "AUT": 0.95, "SWE": 1.17, "NOR": 1.18, "DNK": 1.32, "FIN": 1.08, "IRL": 1.08,
        "ESP": 0.81, "ITA": 0.9, "PRT": 0.68, "GRC": 0.67, "POL": 0.54, "CZE": 0.65,
        "HUN": 0.6, "ROU": 0.55, "BGR": 0.5, "HRV": 0.6, "SVK": 0.6, "SVN": 0.65,
        "IND": 0.12, "PAK": 0.12, "BGD": 0.18, "LKA": 0.3, "IDN": 0.28, "THA": 0.43,
        "VNM": 0.33, "PHL": 0.21, "MYS": 0.32, "SGP": 0.8, "KOR": 0.85, "TWN": 0.7,
        "CHN": 0.55, "HKG": 0.85, "MEX": 0.42, "BRA": 0.38, "ARG": 0.17, "COL": 0.46,
        "CHL": 0.53, "PER": 0.48, "COD": 0.2, "COG": 0.35, "EGY": 0.12, "ZAF": 0.39, "NGA": 0.05, "KEN": 0.3,
        "MAR": 0.35, "TUR": 0.16, "ISR": 0.8, "ARE": 0.7, "SAU": 0.56, "RUS": 0.58,
        "UKR": 0.4, "NZL": 1.14, "LUX": 1.0, "ISL": 1.21,
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
