//
//  CallbackAliases.swift
//  Currency converter
//
//  Created by Ivan Solohub on 07.12.2023.
//

import Foundation

struct CurrencyDataResponse {
    var defaultCurrenciesData: [DefaultCurrenciesData]?
    var currencyData: CurrencyData?
    var currencyViewModels: [CurrencyViewModel]?
}

typealias CallbackString = (String?) -> Void

typealias CurrencyDataCompletion = (CurrencyDataResponse) -> Void
