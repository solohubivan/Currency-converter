//
//  CurrencyData.swift
//  Currency converter
//
//  Created by Ivan Solohub on 30.09.2023.
//

import Foundation

struct CurrencyData: Codable {
    
    var conversion_rates: [String: Double] = [:]
    var time_last_update_utc: String = ""
}
