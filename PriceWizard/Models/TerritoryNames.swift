//
//  TerritoryNames.swift
//  PriceWizard
//
//  ISO 3166-1 alpha-3 territory codes to country/region display names.
//

import Foundation

enum TerritoryNames {
    static let displayNames: [String: String] = [
        "AFG": "Afghanistan", "ALB": "Albania", "DZA": "Algeria", "ASM": "American Samoa",
        "AND": "Andorra", "AGO": "Angola", "AIA": "Anguilla", "ATG": "Antigua and Barbuda",
        "ARG": "Argentina", "ARM": "Armenia", "ABW": "Aruba", "AUS": "Australia",
        "AUT": "Austria", "AZE": "Azerbaijan", "BHS": "Bahamas", "BHR": "Bahrain",
        "BGD": "Bangladesh", "BRB": "Barbados", "BLR": "Belarus", "BEL": "Belgium",
        "BLZ": "Belize", "BEN": "Benin", "BMU": "Bermuda", "BTN": "Bhutan",
        "BOL": "Bolivia", "BES": "Caribbean Netherlands", "BIH": "Bosnia and Herzegovina",
        "BWA": "Botswana", "BRA": "Brazil", "VGB": "British Virgin Islands",
        "BRN": "Brunei", "BGR": "Bulgaria", "BFA": "Burkina Faso", "BDI": "Burundi",
        "CPV": "Cape Verde", "KHM": "Cambodia", "CMR": "Cameroon", "CAN": "Canada",
        "CYM": "Cayman Islands", "CAF": "Central African Republic", "TCD": "Chad",
        "CHL": "Chile", "CHN": "China", "COL": "Colombia", "COM": "Comoros",
        "COD": "Democratic Republic of the Congo", "COG": "Republic of the Congo", "CRI": "Costa Rica", "CIV": "Côte d'Ivoire", "HRV": "Croatia",
        "CUB": "Cuba", "CUW": "Curaçao", "CYP": "Cyprus", "CZE": "Czech Republic",
        "DNK": "Denmark", "DJI": "Djibouti", "DMA": "Dominica", "DOM": "Dominican Republic",
        "ECU": "Ecuador", "EGY": "Egypt", "SLV": "El Salvador", "GNQ": "Equatorial Guinea",
        "ERI": "Eritrea", "EST": "Estonia", "SWZ": "Eswatini", "ETH": "Ethiopia",
        "FLK": "Falkland Islands", "FRO": "Faroe Islands", "FJI": "Fiji",
        "FIN": "Finland", "FRA": "France", "GUF": "French Guiana", "PYF": "French Polynesia",
        "GAB": "Gabon", "GMB": "Gambia", "GEO": "Georgia", "DEU": "Germany",
        "GHA": "Ghana", "GIB": "Gibraltar", "GRC": "Greece", "GRL": "Greenland",
        "GRD": "Grenada", "GLP": "Guadeloupe", "GUM": "Guam", "GTM": "Guatemala",
        "GGY": "Guernsey", "GIN": "Guinea", "GNB": "Guinea-Bissau", "GUY": "Guyana",
        "HTI": "Haiti", "HND": "Honduras", "HKG": "Hong Kong", "HUN": "Hungary",
        "ISL": "Iceland", "IND": "India", "IDN": "Indonesia", "IRN": "Iran",
        "IRQ": "Iraq", "IRL": "Ireland", "IMN": "Isle of Man", "ISR": "Israel",
        "ITA": "Italy", "JAM": "Jamaica", "JPN": "Japan", "JEY": "Jersey",
        "JOR": "Jordan", "KAZ": "Kazakhstan", "KEN": "Kenya", "KIR": "Kiribati",
        "PRK": "North Korea", "KOR": "South Korea", "KWT": "Kuwait", "XKS": "Kosovo", "KGZ": "Kyrgyzstan",
        "LAO": "Laos", "LVA": "Latvia", "LBN": "Lebanon", "LSO": "Lesotho",
        "LBR": "Liberia", "LBY": "Libya", "LIE": "Liechtenstein", "LTU": "Lithuania",
        "LUX": "Luxembourg", "MAC": "Macau", "MDG": "Madagascar", "MWI": "Malawi",
        "MYS": "Malaysia", "MDV": "Maldives", "MLI": "Mali", "MLT": "Malta",
        "MHL": "Marshall Islands", "MTQ": "Martinique", "MRT": "Mauritania",
        "MUS": "Mauritius", "MYT": "Mayotte", "MEX": "Mexico", "FSM": "Micronesia",
        "MDA": "Moldova", "MCO": "Monaco", "MNG": "Mongolia", "MNE": "Montenegro",
        "MSR": "Montserrat", "MAR": "Morocco", "MOZ": "Mozambique", "MMR": "Myanmar",
        "NAM": "Namibia", "NRU": "Nauru", "NPL": "Nepal", "NLD": "Netherlands",
        "NCL": "New Caledonia", "NZL": "New Zealand", "NIC": "Nicaragua", "NER": "Niger",
        "NGA": "Nigeria", "NIU": "Niue", "MKD": "North Macedonia", "MNP": "Northern Mariana Islands",
        "NOR": "Norway", "OMN": "Oman", "PAK": "Pakistan", "PLW": "Palau",
        "PSE": "Palestine", "PAN": "Panama", "PNG": "Papua New Guinea", "PRY": "Paraguay",
        "PER": "Peru", "PHL": "Philippines", "PCN": "Pitcairn Islands", "POL": "Poland",
        "PRT": "Portugal", "PRI": "Puerto Rico", "QAT": "Qatar", "REU": "Réunion",
        "ROU": "Romania", "RUS": "Russia", "RWA": "Rwanda", "BLM": "Saint Barthélemy",
        "SHN": "Saint Helena", "KNA": "Saint Kitts and Nevis", "LCA": "Saint Lucia",
        "MAF": "Saint Martin", "SPM": "Saint Pierre and Miquelon", "VCT": "Saint Vincent and the Grenadines",
        "WSM": "Samoa", "SMR": "San Marino", "STP": "São Tomé and Príncipe", "SAU": "Saudi Arabia",
        "SEN": "Senegal", "SRB": "Serbia", "SYC": "Seychelles", "SLE": "Sierra Leone",
        "SGP": "Singapore", "SXM": "Sint Maarten", "SVK": "Slovakia", "SVN": "Slovenia",
        "SLB": "Solomon Islands", "SOM": "Somalia", "ZAF": "South Africa", "SSD": "South Sudan",
        "ESP": "Spain", "LKA": "Sri Lanka", "SDN": "Sudan", "SUR": "Suriname",
        "SWE": "Sweden", "CHE": "Switzerland", "SYR": "Syria", "TWN": "Taiwan",
        "TJK": "Tajikistan", "TZA": "Tanzania", "THA": "Thailand", "TLS": "Timor-Leste",
        "TGO": "Togo", "TKL": "Tokelau", "TON": "Tonga", "TTO": "Trinidad and Tobago",
        "TUN": "Tunisia", "TUR": "Turkey", "TKM": "Turkmenistan", "TCA": "Turks and Caicos Islands",
        "TUV": "Tuvalu", "UGA": "Uganda", "UKR": "Ukraine", "ARE": "United Arab Emirates",
        "GBR": "United Kingdom", "GB": "United Kingdom", "USA": "United States", "US": "United States",
        "UMI": "United States Minor Outlying Islands", "VIR": "U.S. Virgin Islands",
        "URY": "Uruguay", "UZB": "Uzbekistan", "VUT": "Vanuatu", "VAT": "Vatican City",
        "VEN": "Venezuela", "VNM": "Vietnam", "WLF": "Wallis and Futuna", "ESH": "Western Sahara",
        "YEM": "Yemen", "ZMB": "Zambia", "ZWE": "Zimbabwe"
    ]

    /// Returns the territory name localized for the current locale when possible (via Locale), otherwise the English fallback.
    static func displayName(for territoryCode: String) -> String {
        if let territory = Territory(apiCode: territoryCode) {
            return territory.localizedDisplayName
        }
        return displayNames[territoryCode] ?? territoryCode
    }
}
