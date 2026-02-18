//
//  Territory.swift
//  PriceWizard
//
//  Enum of App Store territories with display names and flag images.
//

import SwiftUI

enum Territory: String, CaseIterable {
    case afghanistan
    case albania
    case algeria
    case americanSamoa
    case andorra
    case angola
    case anguilla
    case antiguaAndBarbuda
    case argentina
    case armenia
    case aruba
    case australia
    case austria
    case azerbaijan
    case bahamas
    case bahrain
    case bangladesh
    case barbados
    case belarus
    case belgium
    case belize
    case benin
    case bermuda
    case bhutan
    case bolivia
    case caribbeanNetherlands
    case bosniaAndHerzegovina
    case botswana
    case brazil
    case britishVirginIslands
    case brunei
    case bulgaria
    case burkinaFaso
    case burundi
    case capeVerde
    case cambodia
    case cameroon
    case canada
    case caymanIslands
    case centralAfricanRepublic
    case chad
    case chile
    case china
    case colombia
    case comoros
    case democraticRepublicOfTheCongo
    case republicOfTheCongo
    case costaRica
    case coteDIvoire
    case croatia
    case cuba
    case curacao
    case cyprus
    case czechRepublic
    case denmark
    case djibouti
    case dominica
    case dominicanRepublic
    case ecuador
    case egypt
    case elSalvador
    case equatorialGuinea
    case eritrea
    case estonia
    case eswatini
    case ethiopia
    case falklandIslands
    case faroeIslands
    case fiji
    case finland
    case france
    case frenchGuiana
    case frenchPolynesia
    case gabon
    case gambia
    case georgia
    case germany
    case ghana
    case gibraltar
    case greece
    case greenland
    case grenada
    case guadeloupe
    case guam
    case guatemala
    case guernsey
    case guinea
    case guineaBissau
    case guyana
    case haiti
    case honduras
    case hongKong
    case hungary
    case iceland
    case india
    case indonesia
    case iran
    case iraq
    case ireland
    case isleOfMan
    case israel
    case italy
    case jamaica
    case japan
    case jersey
    case jordan
    case kazakhstan
    case kenya
    case kiribati
    case northKorea
    case southKorea
    case kosovo
    case kuwait
    case kyrgyzstan
    case laos
    case latvia
    case lebanon
    case lesotho
    case liberia
    case libya
    case liechtenstein
    case lithuania
    case luxembourg
    case macau
    case madagascar
    case malawi
    case malaysia
    case maldives
    case mali
    case malta
    case marshallIslands
    case martinique
    case mauritania
    case mauritius
    case mayotte
    case mexico
    case micronesia
    case moldova
    case monaco
    case mongolia
    case montenegro
    case montserrat
    case morocco
    case mozambique
    case myanmar
    case namibia
    case nauru
    case nepal
    case netherlands
    case newCaledonia
    case newZealand
    case nicaragua
    case niger
    case nigeria
    case niue
    case northMacedonia
    case northernMarianaIslands
    case norway
    case oman
    case pakistan
    case palau
    case palestine
    case panama
    case papuaNewGuinea
    case paraguay
    case peru
    case philippines
    case pitcairnIslands
    case poland
    case portugal
    case puertoRico
    case qatar
    case reunion
    case romania
    case russia
    case rwanda
    case saintBarthelemy
    case saintHelena
    case saintKittsAndNevis
    case saintLucia
    case saintMartin
    case saintPierreAndMiquelon
    case saintVincentAndTheGrenadines
    case samoa
    case sanMarino
    case saoTomeAndPrincipe
    case saudiArabia
    case senegal
    case serbia
    case seychelles
    case sierraLeone
    case singapore
    case sintMaarten
    case slovakia
    case slovenia
    case solomonIslands
    case somalia
    case southAfrica
    case southSudan
    case spain
    case sriLanka
    case sudan
    case suriname
    case sweden
    case switzerland
    case syria
    case taiwan
    case tajikistan
    case tanzania
    case thailand
    case timorLeste
    case togo
    case tokelau
    case tonga
    case trinidadAndTobago
    case tunisia
    case turkey
    case turkmenistan
    case turksAndCaicosIslands
    case tuvalu
    case uganda
    case ukraine
    case unitedArabEmirates
    case unitedKingdom
    case unitedStates
    case unitedStatesMinorOutlyingIslands
    case usVirginIslands
    case uruguay
    case uzbekistan
    case vanuatu
    case vaticanCity
    case venezuela
    case vietnam
    case wallisAndFutuna
    case westernSahara
    case yemen
    case zambia
    case zimbabwe

    /// Display name for UI.
    var displayName: String {
        switch self {
        case .afghanistan: return "Afghanistan"
        case .albania: return "Albania"
        case .algeria: return "Algeria"
        case .americanSamoa: return "American Samoa"
        case .andorra: return "Andorra"
        case .angola: return "Angola"
        case .anguilla: return "Anguilla"
        case .antiguaAndBarbuda: return "Antigua and Barbuda"
        case .argentina: return "Argentina"
        case .armenia: return "Armenia"
        case .aruba: return "Aruba"
        case .australia: return "Australia"
        case .austria: return "Austria"
        case .azerbaijan: return "Azerbaijan"
        case .bahamas: return "Bahamas"
        case .bahrain: return "Bahrain"
        case .bangladesh: return "Bangladesh"
        case .barbados: return "Barbados"
        case .belarus: return "Belarus"
        case .belgium: return "Belgium"
        case .belize: return "Belize"
        case .benin: return "Benin"
        case .bermuda: return "Bermuda"
        case .bhutan: return "Bhutan"
        case .bolivia: return "Bolivia"
        case .caribbeanNetherlands: return "Caribbean Netherlands"
        case .bosniaAndHerzegovina: return "Bosnia and Herzegovina"
        case .botswana: return "Botswana"
        case .brazil: return "Brazil"
        case .britishVirginIslands: return "British Virgin Islands"
        case .brunei: return "Brunei"
        case .bulgaria: return "Bulgaria"
        case .burkinaFaso: return "Burkina Faso"
        case .burundi: return "Burundi"
        case .capeVerde: return "Cape Verde"
        case .cambodia: return "Cambodia"
        case .cameroon: return "Cameroon"
        case .canada: return "Canada"
        case .caymanIslands: return "Cayman Islands"
        case .centralAfricanRepublic: return "Central African Republic"
        case .chad: return "Chad"
        case .chile: return "Chile"
        case .china: return "China"
        case .colombia: return "Colombia"
        case .comoros: return "Comoros"
        case .democraticRepublicOfTheCongo: return "Democratic Republic of the Congo"
        case .republicOfTheCongo: return "Republic of the Congo"
        case .costaRica: return "Costa Rica"
        case .coteDIvoire: return "Côte d'Ivoire"
        case .croatia: return "Croatia"
        case .cuba: return "Cuba"
        case .curacao: return "Curaçao"
        case .cyprus: return "Cyprus"
        case .czechRepublic: return "Czech Republic"
        case .denmark: return "Denmark"
        case .djibouti: return "Djibouti"
        case .dominica: return "Dominica"
        case .dominicanRepublic: return "Dominican Republic"
        case .ecuador: return "Ecuador"
        case .egypt: return "Egypt"
        case .elSalvador: return "El Salvador"
        case .equatorialGuinea: return "Equatorial Guinea"
        case .eritrea: return "Eritrea"
        case .estonia: return "Estonia"
        case .eswatini: return "Eswatini"
        case .ethiopia: return "Ethiopia"
        case .falklandIslands: return "Falkland Islands"
        case .faroeIslands: return "Faroe Islands"
        case .fiji: return "Fiji"
        case .finland: return "Finland"
        case .france: return "France"
        case .frenchGuiana: return "French Guiana"
        case .frenchPolynesia: return "French Polynesia"
        case .gabon: return "Gabon"
        case .gambia: return "Gambia"
        case .georgia: return "Georgia"
        case .germany: return "Germany"
        case .ghana: return "Ghana"
        case .gibraltar: return "Gibraltar"
        case .greece: return "Greece"
        case .greenland: return "Greenland"
        case .grenada: return "Grenada"
        case .guadeloupe: return "Guadeloupe"
        case .guam: return "Guam"
        case .guatemala: return "Guatemala"
        case .guernsey: return "Guernsey"
        case .guinea: return "Guinea"
        case .guineaBissau: return "Guinea-Bissau"
        case .guyana: return "Guyana"
        case .haiti: return "Haiti"
        case .honduras: return "Honduras"
        case .hongKong: return "Hong Kong"
        case .hungary: return "Hungary"
        case .iceland: return "Iceland"
        case .india: return "India"
        case .indonesia: return "Indonesia"
        case .iran: return "Iran"
        case .iraq: return "Iraq"
        case .ireland: return "Ireland"
        case .isleOfMan: return "Isle of Man"
        case .israel: return "Israel"
        case .italy: return "Italy"
        case .jamaica: return "Jamaica"
        case .japan: return "Japan"
        case .jersey: return "Jersey"
        case .jordan: return "Jordan"
        case .kazakhstan: return "Kazakhstan"
        case .kenya: return "Kenya"
        case .kiribati: return "Kiribati"
        case .northKorea: return "North Korea"
        case .southKorea: return "South Korea"
        case .kosovo: return "Kosovo"
        case .kuwait: return "Kuwait"
        case .kyrgyzstan: return "Kyrgyzstan"
        case .laos: return "Laos"
        case .latvia: return "Latvia"
        case .lebanon: return "Lebanon"
        case .lesotho: return "Lesotho"
        case .liberia: return "Liberia"
        case .libya: return "Libya"
        case .liechtenstein: return "Liechtenstein"
        case .lithuania: return "Lithuania"
        case .luxembourg: return "Luxembourg"
        case .macau: return "Macau"
        case .madagascar: return "Madagascar"
        case .malawi: return "Malawi"
        case .malaysia: return "Malaysia"
        case .maldives: return "Maldives"
        case .mali: return "Mali"
        case .malta: return "Malta"
        case .marshallIslands: return "Marshall Islands"
        case .martinique: return "Martinique"
        case .mauritania: return "Mauritania"
        case .mauritius: return "Mauritius"
        case .mayotte: return "Mayotte"
        case .mexico: return "Mexico"
        case .micronesia: return "Micronesia"
        case .moldova: return "Moldova"
        case .monaco: return "Monaco"
        case .mongolia: return "Mongolia"
        case .montenegro: return "Montenegro"
        case .montserrat: return "Montserrat"
        case .morocco: return "Morocco"
        case .mozambique: return "Mozambique"
        case .myanmar: return "Myanmar"
        case .namibia: return "Namibia"
        case .nauru: return "Nauru"
        case .nepal: return "Nepal"
        case .netherlands: return "Netherlands"
        case .newCaledonia: return "New Caledonia"
        case .newZealand: return "New Zealand"
        case .nicaragua: return "Nicaragua"
        case .niger: return "Niger"
        case .nigeria: return "Nigeria"
        case .niue: return "Niue"
        case .northMacedonia: return "North Macedonia"
        case .northernMarianaIslands: return "Northern Mariana Islands"
        case .norway: return "Norway"
        case .oman: return "Oman"
        case .pakistan: return "Pakistan"
        case .palau: return "Palau"
        case .palestine: return "Palestine"
        case .panama: return "Panama"
        case .papuaNewGuinea: return "Papua New Guinea"
        case .paraguay: return "Paraguay"
        case .peru: return "Peru"
        case .philippines: return "Philippines"
        case .pitcairnIslands: return "Pitcairn Islands"
        case .poland: return "Poland"
        case .portugal: return "Portugal"
        case .puertoRico: return "Puerto Rico"
        case .qatar: return "Qatar"
        case .reunion: return "Réunion"
        case .romania: return "Romania"
        case .russia: return "Russia"
        case .rwanda: return "Rwanda"
        case .saintBarthelemy: return "Saint Barthélemy"
        case .saintHelena: return "Saint Helena"
        case .saintKittsAndNevis: return "Saint Kitts and Nevis"
        case .saintLucia: return "Saint Lucia"
        case .saintMartin: return "Saint Martin"
        case .saintPierreAndMiquelon: return "Saint Pierre and Miquelon"
        case .saintVincentAndTheGrenadines: return "Saint Vincent and the Grenadines"
        case .samoa: return "Samoa"
        case .sanMarino: return "San Marino"
        case .saoTomeAndPrincipe: return "São Tomé and Príncipe"
        case .saudiArabia: return "Saudi Arabia"
        case .senegal: return "Senegal"
        case .serbia: return "Serbia"
        case .seychelles: return "Seychelles"
        case .sierraLeone: return "Sierra Leone"
        case .singapore: return "Singapore"
        case .sintMaarten: return "Sint Maarten"
        case .slovakia: return "Slovakia"
        case .slovenia: return "Slovenia"
        case .solomonIslands: return "Solomon Islands"
        case .somalia: return "Somalia"
        case .southAfrica: return "South Africa"
        case .southSudan: return "South Sudan"
        case .spain: return "Spain"
        case .sriLanka: return "Sri Lanka"
        case .sudan: return "Sudan"
        case .suriname: return "Suriname"
        case .sweden: return "Sweden"
        case .switzerland: return "Switzerland"
        case .syria: return "Syria"
        case .taiwan: return "Taiwan"
        case .tajikistan: return "Tajikistan"
        case .tanzania: return "Tanzania"
        case .thailand: return "Thailand"
        case .timorLeste: return "Timor-Leste"
        case .togo: return "Togo"
        case .tokelau: return "Tokelau"
        case .tonga: return "Tonga"
        case .trinidadAndTobago: return "Trinidad and Tobago"
        case .tunisia: return "Tunisia"
        case .turkey: return "Turkey"
        case .turkmenistan: return "Turkmenistan"
        case .turksAndCaicosIslands: return "Turks and Caicos Islands"
        case .tuvalu: return "Tuvalu"
        case .uganda: return "Uganda"
        case .ukraine: return "Ukraine"
        case .unitedArabEmirates: return "United Arab Emirates"
        case .unitedKingdom: return "United Kingdom"
        case .unitedStates: return "United States"
        case .unitedStatesMinorOutlyingIslands: return "United States Minor Outlying Islands"
        case .usVirginIslands: return "U.S. Virgin Islands"
        case .uruguay: return "Uruguay"
        case .uzbekistan: return "Uzbekistan"
        case .vanuatu: return "Vanuatu"
        case .vaticanCity: return "Vatican City"
        case .venezuela: return "Venezuela"
        case .vietnam: return "Vietnam"
        case .wallisAndFutuna: return "Wallis and Futuna"
        case .westernSahara: return "Western Sahara"
        case .yemen: return "Yemen"
        case .zambia: return "Zambia"
        case .zimbabwe: return "Zimbabwe"
        }
    }

    /// ISO 3166-1 alpha-2 region code (e.g. "US", "GB") for system localization.
    var regionCode: String {
        flagImageName.uppercased()
    }

    /// Display name localized for the current locale (uses system region names).
    var localizedDisplayName: String {
        Locale.current.localizedString(forRegionCode: regionCode) ?? displayName
    }

    /// Flag image from Assets.xcassets/flags (ISO 3166-1 alpha-2 asset name).
    var image: Image {
        Image("flags/\(flagImageName)")
    }

    /// Asset name (alpha-2) for the flag image inside the flags namespace.
    private var flagImageName: String {
        switch self {
        case .afghanistan: return "af"
        case .albania: return "al"
        case .algeria: return "dz"
        case .americanSamoa: return "as"
        case .andorra: return "ad"
        case .angola: return "ao"
        case .anguilla: return "ai"
        case .antiguaAndBarbuda: return "ag"
        case .argentina: return "ar"
        case .armenia: return "am"
        case .aruba: return "aw"
        case .australia: return "au"
        case .austria: return "at"
        case .azerbaijan: return "az"
        case .bahamas: return "bs"
        case .bahrain: return "bh"
        case .bangladesh: return "bd"
        case .barbados: return "bb"
        case .belarus: return "by"
        case .belgium: return "be"
        case .belize: return "bz"
        case .benin: return "bj"
        case .bermuda: return "bm"
        case .bhutan: return "bt"
        case .bolivia: return "bo"
        case .caribbeanNetherlands: return "bq"
        case .bosniaAndHerzegovina: return "ba"
        case .botswana: return "bw"
        case .brazil: return "br"
        case .britishVirginIslands: return "vg"
        case .brunei: return "bn"
        case .bulgaria: return "bg"
        case .burkinaFaso: return "bf"
        case .burundi: return "bi"
        case .capeVerde: return "cv"
        case .cambodia: return "kh"
        case .cameroon: return "cm"
        case .canada: return "ca"
        case .caymanIslands: return "ky"
        case .centralAfricanRepublic: return "cf"
        case .chad: return "td"
        case .chile: return "cl"
        case .china: return "cn"
        case .colombia: return "co"
        case .comoros: return "km"
        case .democraticRepublicOfTheCongo: return "cd"
        case .republicOfTheCongo: return "cg"
        case .costaRica: return "cr"
        case .coteDIvoire: return "ci"
        case .croatia: return "hr"
        case .cuba: return "cu"
        case .curacao: return "cw"
        case .cyprus: return "cy"
        case .czechRepublic: return "cz"
        case .denmark: return "dk"
        case .djibouti: return "dj"
        case .dominica: return "dm"
        case .dominicanRepublic: return "do"
        case .ecuador: return "ec"
        case .egypt: return "eg"
        case .elSalvador: return "sv"
        case .equatorialGuinea: return "gq"
        case .eritrea: return "er"
        case .estonia: return "ee"
        case .eswatini: return "sz"
        case .ethiopia: return "et"
        case .falklandIslands: return "fk"
        case .faroeIslands: return "fo"
        case .fiji: return "fj"
        case .finland: return "fi"
        case .france: return "fr"
        case .frenchGuiana: return "gf"
        case .frenchPolynesia: return "pf"
        case .gabon: return "ga"
        case .gambia: return "gm"
        case .georgia: return "ge"
        case .germany: return "de"
        case .ghana: return "gh"
        case .gibraltar: return "gi"
        case .greece: return "gr"
        case .greenland: return "gl"
        case .grenada: return "gd"
        case .guadeloupe: return "gp"
        case .guam: return "gu"
        case .guatemala: return "gt"
        case .guernsey: return "gg"
        case .guinea: return "gn"
        case .guineaBissau: return "gw"
        case .guyana: return "gy"
        case .haiti: return "ht"
        case .honduras: return "hn"
        case .hongKong: return "hk"
        case .hungary: return "hu"
        case .iceland: return "is"
        case .india: return "in"
        case .indonesia: return "id"
        case .iran: return "ir"
        case .iraq: return "iq"
        case .ireland: return "ie"
        case .isleOfMan: return "im"
        case .israel: return "il"
        case .italy: return "it"
        case .jamaica: return "jm"
        case .japan: return "jp"
        case .jersey: return "je"
        case .jordan: return "jo"
        case .kazakhstan: return "kz"
        case .kenya: return "ke"
        case .kiribati: return "ki"
        case .northKorea: return "kp"
        case .southKorea: return "kr"
        case .kosovo: return "xk"
        case .kuwait: return "kw"
        case .kyrgyzstan: return "kg"
        case .laos: return "la"
        case .latvia: return "lv"
        case .lebanon: return "lb"
        case .lesotho: return "ls"
        case .liberia: return "lr"
        case .libya: return "ly"
        case .liechtenstein: return "li"
        case .lithuania: return "lt"
        case .luxembourg: return "lu"
        case .macau: return "mo"
        case .madagascar: return "mg"
        case .malawi: return "mw"
        case .malaysia: return "my"
        case .maldives: return "mv"
        case .mali: return "ml"
        case .malta: return "mt"
        case .marshallIslands: return "mh"
        case .martinique: return "mq"
        case .mauritania: return "mr"
        case .mauritius: return "mu"
        case .mayotte: return "yt"
        case .mexico: return "mx"
        case .micronesia: return "fm"
        case .moldova: return "md"
        case .monaco: return "mc"
        case .mongolia: return "mn"
        case .montenegro: return "me"
        case .montserrat: return "ms"
        case .morocco: return "ma"
        case .mozambique: return "mz"
        case .myanmar: return "mm"
        case .namibia: return "na"
        case .nauru: return "nr"
        case .nepal: return "np"
        case .netherlands: return "nl"
        case .newCaledonia: return "nc"
        case .newZealand: return "nz"
        case .nicaragua: return "ni"
        case .niger: return "ne"
        case .nigeria: return "ng"
        case .niue: return "nu"
        case .northMacedonia: return "mk"
        case .northernMarianaIslands: return "mp"
        case .norway: return "no"
        case .oman: return "om"
        case .pakistan: return "pk"
        case .palau: return "pw"
        case .palestine: return "ps"
        case .panama: return "pa"
        case .papuaNewGuinea: return "pg"
        case .paraguay: return "py"
        case .peru: return "pe"
        case .philippines: return "ph"
        case .pitcairnIslands: return "pn"
        case .poland: return "pl"
        case .portugal: return "pt"
        case .puertoRico: return "pr"
        case .qatar: return "qa"
        case .reunion: return "re"
        case .romania: return "ro"
        case .russia: return "ru"
        case .rwanda: return "rw"
        case .saintBarthelemy: return "bl"
        case .saintHelena: return "sh"
        case .saintKittsAndNevis: return "kn"
        case .saintLucia: return "lc"
        case .saintMartin: return "mf"
        case .saintPierreAndMiquelon: return "pm"
        case .saintVincentAndTheGrenadines: return "vc"
        case .samoa: return "ws"
        case .sanMarino: return "sm"
        case .saoTomeAndPrincipe: return "st"
        case .saudiArabia: return "sa"
        case .senegal: return "sn"
        case .serbia: return "rs"
        case .seychelles: return "sc"
        case .sierraLeone: return "sl"
        case .singapore: return "sg"
        case .sintMaarten: return "sx"
        case .slovakia: return "sk"
        case .slovenia: return "si"
        case .solomonIslands: return "sb"
        case .somalia: return "so"
        case .southAfrica: return "za"
        case .southSudan: return "ss"
        case .spain: return "es"
        case .sriLanka: return "lk"
        case .sudan: return "sd"
        case .suriname: return "sr"
        case .sweden: return "se"
        case .switzerland: return "ch"
        case .syria: return "sy"
        case .taiwan: return "tw"
        case .tajikistan: return "tj"
        case .tanzania: return "tz"
        case .thailand: return "th"
        case .timorLeste: return "tl"
        case .togo: return "tg"
        case .tokelau: return "tk"
        case .tonga: return "to"
        case .trinidadAndTobago: return "tt"
        case .tunisia: return "tn"
        case .turkey: return "tr"
        case .turkmenistan: return "tm"
        case .turksAndCaicosIslands: return "tc"
        case .tuvalu: return "tv"
        case .uganda: return "ug"
        case .ukraine: return "ua"
        case .unitedArabEmirates: return "ae"
        case .unitedKingdom: return "gb"
        case .unitedStates: return "us"
        case .unitedStatesMinorOutlyingIslands: return "um"
        case .usVirginIslands: return "vi"
        case .uruguay: return "uy"
        case .uzbekistan: return "uz"
        case .vanuatu: return "vu"
        case .vaticanCity: return "va"
        case .venezuela: return "ve"
        case .vietnam: return "vn"
        case .wallisAndFutuna: return "wf"
        case .westernSahara: return "eh"
        case .yemen: return "ye"
        case .zambia: return "zm"
        case .zimbabwe: return "zw"
        }
    }

    /// Creates a territory from an App Store Connect API territory code (e.g. "USA", "GBR", "US", "GB").
    init?(apiCode: String) {
        guard let territory = Self.codeToTerritory[apiCode] else { return nil }
        self = territory
    }

    /// Maps App Store Connect territory IDs to enum cases.
    private static let codeToTerritory: [String: Territory] = [
        "AFG": .afghanistan, "ALB": .albania, "DZA": .algeria, "ASM": .americanSamoa,
        "AND": .andorra, "AGO": .angola, "AIA": .anguilla, "ATG": .antiguaAndBarbuda,
        "ARG": .argentina, "ARM": .armenia, "ABW": .aruba, "AUS": .australia,
        "AUT": .austria, "AZE": .azerbaijan, "BHS": .bahamas, "BHR": .bahrain,
        "BGD": .bangladesh, "BRB": .barbados, "BLR": .belarus, "BEL": .belgium,
        "BLZ": .belize, "BEN": .benin, "BMU": .bermuda, "BTN": .bhutan,
        "BOL": .bolivia, "BES": .caribbeanNetherlands, "BIH": .bosniaAndHerzegovina,
        "BWA": .botswana, "BRA": .brazil, "VGB": .britishVirginIslands,
        "BRN": .brunei, "BGR": .bulgaria, "BFA": .burkinaFaso, "BDI": .burundi,
        "CPV": .capeVerde, "KHM": .cambodia, "CMR": .cameroon, "CAN": .canada,
        "CYM": .caymanIslands, "CAF": .centralAfricanRepublic, "TCD": .chad,
        "CHL": .chile, "CHN": .china, "COL": .colombia, "COM": .comoros,
        "COD": .democraticRepublicOfTheCongo, "COG": .republicOfTheCongo,
        "CRI": .costaRica, "CIV": .coteDIvoire, "HRV": .croatia, "CUB": .cuba,
        "CUW": .curacao, "CYP": .cyprus, "CZE": .czechRepublic, "DNK": .denmark,
        "DJI": .djibouti, "DMA": .dominica, "DOM": .dominicanRepublic,
        "ECU": .ecuador, "EGY": .egypt, "SLV": .elSalvador, "GNQ": .equatorialGuinea,
        "ERI": .eritrea, "EST": .estonia, "SWZ": .eswatini, "ETH": .ethiopia,
        "FLK": .falklandIslands, "FRO": .faroeIslands, "FJI": .fiji, "FIN": .finland,
        "FRA": .france, "GUF": .frenchGuiana, "PYF": .frenchPolynesia,
        "GAB": .gabon, "GMB": .gambia, "GEO": .georgia, "DEU": .germany,
        "GHA": .ghana, "GIB": .gibraltar, "GRC": .greece, "GRL": .greenland,
        "GRD": .grenada, "GLP": .guadeloupe, "GUM": .guam, "GTM": .guatemala,
        "GGY": .guernsey, "GIN": .guinea, "GNB": .guineaBissau, "GUY": .guyana,
        "HTI": .haiti, "HND": .honduras, "HKG": .hongKong, "HUN": .hungary,
        "ISL": .iceland, "IND": .india, "IDN": .indonesia, "IRN": .iran,
        "IRQ": .iraq, "IRL": .ireland, "IMN": .isleOfMan, "ISR": .israel,
        "ITA": .italy, "JAM": .jamaica, "JPN": .japan, "JEY": .jersey,
        "JOR": .jordan, "KAZ": .kazakhstan, "KEN": .kenya, "KIR": .kiribati,
        "PRK": .northKorea, "KOR": .southKorea, "KWT": .kuwait, "XKS": .kosovo,
        "KGZ": .kyrgyzstan, "LAO": .laos, "LVA": .latvia, "LBN": .lebanon,
        "LSO": .lesotho, "LBR": .liberia, "LBY": .libya, "LIE": .liechtenstein,
        "LTU": .lithuania, "LUX": .luxembourg, "MAC": .macau, "MDG": .madagascar,
        "MWI": .malawi, "MYS": .malaysia, "MDV": .maldives, "MLI": .mali,
        "MLT": .malta, "MHL": .marshallIslands, "MTQ": .martinique,
        "MRT": .mauritania, "MUS": .mauritius, "MYT": .mayotte, "MEX": .mexico,
        "FSM": .micronesia, "MDA": .moldova, "MCO": .monaco, "MNG": .mongolia,
        "MNE": .montenegro, "MSR": .montserrat, "MAR": .morocco, "MOZ": .mozambique,
        "MMR": .myanmar, "NAM": .namibia, "NRU": .nauru, "NPL": .nepal,
        "NLD": .netherlands, "NCL": .newCaledonia, "NZL": .newZealand,
        "NIC": .nicaragua, "NER": .niger, "NGA": .nigeria, "NIU": .niue,
        "MKD": .northMacedonia, "MNP": .northernMarianaIslands, "NOR": .norway,
        "OMN": .oman, "PAK": .pakistan, "PLW": .palau, "PSE": .palestine,
        "PAN": .panama, "PNG": .papuaNewGuinea, "PRY": .paraguay, "PER": .peru,
        "PHL": .philippines, "PCN": .pitcairnIslands, "POL": .poland,
        "PRT": .portugal, "PRI": .puertoRico, "QAT": .qatar, "REU": .reunion,
        "ROU": .romania, "RUS": .russia, "RWA": .rwanda, "BLM": .saintBarthelemy,
        "SHN": .saintHelena, "KNA": .saintKittsAndNevis, "LCA": .saintLucia,
        "MAF": .saintMartin, "SPM": .saintPierreAndMiquelon,
        "VCT": .saintVincentAndTheGrenadines, "WSM": .samoa, "SMR": .sanMarino,
        "STP": .saoTomeAndPrincipe, "SAU": .saudiArabia, "SEN": .senegal,
        "SRB": .serbia, "SYC": .seychelles, "SLE": .sierraLeone, "SGP": .singapore,
        "SXM": .sintMaarten, "SVK": .slovakia, "SVN": .slovenia,
        "SLB": .solomonIslands, "SOM": .somalia, "ZAF": .southAfrica,
        "SSD": .southSudan, "ESP": .spain, "LKA": .sriLanka, "SDN": .sudan,
        "SUR": .suriname, "SWE": .sweden, "CHE": .switzerland, "SYR": .syria,
        "TWN": .taiwan, "TJK": .tajikistan, "TZA": .tanzania, "THA": .thailand,
        "TLS": .timorLeste, "TGO": .togo, "TKL": .tokelau, "TON": .tonga,
        "TTO": .trinidadAndTobago, "TUN": .tunisia, "TUR": .turkey,
        "TKM": .turkmenistan, "TCA": .turksAndCaicosIslands, "TUV": .tuvalu,
        "UGA": .uganda, "UKR": .ukraine, "ARE": .unitedArabEmirates,
        "GBR": .unitedKingdom, "GB": .unitedKingdom,
        "USA": .unitedStates, "US": .unitedStates,
        "UMI": .unitedStatesMinorOutlyingIslands, "VIR": .usVirginIslands,
        "URY": .uruguay, "UZB": .uzbekistan, "VUT": .vanuatu, "VAT": .vaticanCity,
        "VEN": .venezuela, "VNM": .vietnam, "WLF": .wallisAndFutuna,
        "ESH": .westernSahara, "YEM": .yemen, "ZMB": .zambia, "ZWE": .zimbabwe
    ]
}
