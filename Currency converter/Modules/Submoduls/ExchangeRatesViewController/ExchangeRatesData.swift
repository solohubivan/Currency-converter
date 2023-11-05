//
//  ExchangeRatesData.swift
//  Currency converter
//
//  Created by Ivan Solohub on 03.11.2023.
//

import Foundation

struct ExchangeRatesData: Codable {
    var date: String = ""
    var bank: String = ""
    var baseCurrency: Int = 0
    var baseCurrencyLit: String = ""
    var exchangeRate: [CurrencyExchangeRate] = []
}

struct CurrencyExchangeRate: Codable {
    var baseCurrency: String = ""
    var currency: String = ""
    var saleRateNB: Double = 0.0
    var purchaseRateNB: Double = 0.0
    var saleRate: Double?
    var purchaseRate: Double?
}
