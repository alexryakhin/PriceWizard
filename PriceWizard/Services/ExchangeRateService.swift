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
            "USD": 1.0, "EUR": 0.92, "GBP": 0.79, "AUD": 1.53, "CAD": 1.36,
            "BRL": 5.0, "CHF": 0.88, "CNY": 7.24, "INR": 83.0, "JPY": 150.0,
            "KRW": 1320.0, "MXN": 17.0, "PLN": 3.95, "SEK": 10.5, "NOK": 10.8,
            "DKK": 6.85, "HKD": 7.82, "SGD": 1.34, "NZD": 1.64, "THB": 35.0,
            "AED": 3.67, "SAR": 3.75, "ILS": 3.7, "TRY": 32.0, "ZAR": 18.5,
            "RUB": 92.0, "IDR": 15700.0, "MYR": 4.7, "PHP": 56.0, "CZK": 22.5,
            "HUF": 350.0, "RON": 4.55, "BGN": 1.8, "HRK": 6.9, "EGP": 31.0,
            "NGN": 1550.0, "PKR": 278.0, "BBD": 2.0, "BSD": 1.0, "BZD": 2.0,
            "XCD": 2.7, "JMD": 155.0, "TTD": 6.8, "COP": 3950.0, "PEN": 3.7,
            "CLP": 920.0, "ARS": 870.0, "UYU": 39.0, "BOB": 6.9, "PYG": 7300.0,
            "VND": 24500.0, "TWD": 31.5, "KWD": 0.31, "QAR": 3.64, "BHD": 0.376
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
