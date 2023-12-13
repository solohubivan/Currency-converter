//
//  CurrencyData.swift
//  Currency converter
//
//  Created by Ivan Solohub on 30.09.2023.
//

import Foundation

struct CurrencyRate: Codable {
    var currencyCode: String
    var value: Double
}

struct CurrencyData: Codable {
    var conversionRates: [String: Double] = [:]
    var timeLastUpdateUtc: String = ""

    enum CodingKeys: String, CodingKey {
        case conversionRates = "conversion_rates"
        case timeLastUpdateUtc = "time_last_update_utc"
    }

    func toCurrencyRateArray() -> [CurrencyRate] {
        return conversionRates.map { CurrencyRate(currencyCode: $0.key, value: $0.value) }
    }
}

struct DefaultCurrenciesData: Codable {
    var ccy: String = ""
    var baseCcy: String = ""
    var buy: String = ""
    var sale: String = ""

    enum CodingKeys: String, CodingKey {
        case ccy
        case baseCcy = "base_ccy"
        case buy
        case sale
    }
}
