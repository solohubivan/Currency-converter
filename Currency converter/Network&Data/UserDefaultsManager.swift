//
//  UserDefaultsManager.swift
//  Currency converter
//
//  Created by Ivan Solohub on 30.11.2023.
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let defaults = UserDefaults.standard

    private init() {}

    func saveBaseCurrencies(_ currencies: [CurrencyViewModel]) {
        saveCurrencies(currencies, forKey: "baseCurrencies")
    }
    
    func saveAllCurrenciesData(_ currencies: [CurrencyViewModel]) {
        saveCurrencies(currencies, forKey: "allCurrenciesData")
    }

    func loadAllCurrenciesData() -> [CurrencyViewModel]? {
        return loadCurrencies(forKey: "allCurrenciesData")
    }
    
    func loadBaseCurrencies() -> [CurrencyViewModel]? {
        return loadCurrencies(forKey: "baseCurrencies")
    }

    private func saveCurrencies(_ currencies: [CurrencyViewModel], forKey key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(currencies) {
            defaults.set(encoded, forKey: key)
        }
    }

    private func loadCurrencies(forKey key: String) -> [CurrencyViewModel]? {
        if let savedData = defaults.data(forKey: key) {
            if let loadedCurrencies = try? JSONDecoder().decode([CurrencyViewModel].self, from: savedData) {
                return loadedCurrencies
            }
        }
        return nil
    }
}
