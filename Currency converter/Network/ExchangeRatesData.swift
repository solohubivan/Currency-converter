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
    var exchangeRate: [CurrencyExchangeRate] = []
}

struct CurrencyExchangeRate: Codable {
    var currency: String = ""
    var saleRateNB: Double = 0.0
    var purchaseRateNB: Double = 0.0
}
