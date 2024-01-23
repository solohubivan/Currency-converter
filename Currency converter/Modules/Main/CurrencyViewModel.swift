//
//  CurrencyViewModel.swift
//  Currency converter
//
//  Created by Ivan Solohub on 23.01.2024.
//

import Foundation

struct CurrencyViewModel: Codable, Equatable {
    var name: String
    var sellRate: Double
    var buyRate: Double
    var calculatedResult: Double?
}
