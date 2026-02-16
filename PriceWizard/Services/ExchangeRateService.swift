//
//  ExchangeRateService.swift
//  PriceWizard
//
//  Fetches USD exchange rates for currency conversion.
//

import Foundation

struct ExchangeRateService {
    /// Rates from USD to currency code. E.g. rates["EUR"] = 0.92 means 1 USD = 0.92 EUR.
    /// To convert price in EUR to USD: price / rates["EUR"]
    static func fetchRatesFromUSD() async -> [String: Double] {
        let fallback = fallbackRates
        guard let url = URL(string: "https://api.frankfurter.dev/v1/latest?base=USD") else { return fallback }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return fallback }
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let rates = json?["rates"] as? [String: Double] ?? [:]
            guard !rates.isEmpty else { return fallback }
            var result = fallback
            for (key, value) in rates {
                result[key] = value
            }
            result["USD"] = 1.0
            return result
        } catch {
            return fallback
        }
    }

    private static var fallbackRates: [String: Double] {
        [
            "AED": 3.67,
            "AUD": 1.4183,
            "BRL": 5.2197,
            "CAD": 1.3624,
            "CLP": 862.64,
            "CHF": 0.76893,
            "COP": 3660.77,
            "CNY": 6.9086,
            "CZK": 20.454,
            "DKK": 6.2982,
            "EUR": 0.84303,
            "EGP": 46.7,
            "GBP": 0.73478,
            "HKD": 7.817,
            "HUF": 319.58,
            "IDR": 16823,
            "ILS": 3.0896,
            "INR": 90.61,
            "ISK": 122.24,
            "JPY": 153.29,
            "KZT": 494.62,
            "TZS": 2609.33,
            "KRW": 1446.45,
            "MXN": 17.2205,
            "MYR": 3.9075,
            "NGN": 1354.15,
            "NOK": 9.5481,
            "NZD": 1.6602,
            "PEN": 3.35,
            "PHP": 57.857,
            "PKR": 279.5,
            "PLN": 3.5534,
            "RON": 4.2949,
            "RUB": 123.06,
            "SAR": 3.75,
            "SEK": 8.9575,
            "SGD": 1.2639,
            "THB": 31.075,
            "TRY": 43.74,
            "TWD": 31.38,
            "QAR": 3.64,
            "ZAR": 16.0336,
            "VND": 24500.0,
        ]
    }

    /// Convert amount in given currency to USD.
    /// rate = how many units of currency per 1 USD. So amount_usd = amount / rate.
    static func toUSD(amount: Double, currency: String, rates: [String: Double]) -> Double? {
        let code = currency.isEmpty ? "USD" : currency.uppercased()
        guard let rate = rates[code], rate > 0 else { return nil }
        return amount / rate
    }
}
