//
//  NetworkService.swift
//  Currency converter
//
//  Created by Ivan Solohub on 29.11.2023.
//

import Foundation

class NetworkService {
    static let shared = NetworkService()

    private init() {}

    private var apiKey: String {
        guard let filePath = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath),
              let value = plist["APIKey"] as? String else {
            fatalError("Couldn't find key 'APIKey' in 'Config.plist'")
        }
        return value
    }

    func getCurrencyData(completion: @escaping ([DefaultCurrenciesData]?, CurrencyData?, [CurrencyViewModel]?) -> Void) {
        let session = URLSession.shared
        let allCurrenciesURL = URL(string: "https://v6.exchangerate-api.com/v6/\(apiKey)/latest/USD")!
        let defaultCurrenciesURL = URL(string: "https://api.privatbank.ua/p24api/pubinfo?json&exchange&coursid=5")!

        let firstTask = session.dataTask(with: defaultCurrenciesURL) { (data, _, error) in
            guard error == nil, let data = data else { return }

            do {
                let defaultCurrencies = try JSONDecoder().decode([DefaultCurrenciesData].self, from: data)
                completion(defaultCurrencies, nil, nil)
            } catch {
                completion(nil, nil, nil)
            }
        }

        let secondTask = session.dataTask(with: allCurrenciesURL) { (data, _, error) in
            guard error == nil, let data = data else { return }

            do {
                let currencyData = try JSONDecoder().decode(CurrencyData.self, from: data)
                let currencyRates = currencyData.toCurrencyRateArray()
                let allCurrenciesData = currencyRates.map { CurrencyViewModel(name: $0.currencyCode, sellRate: $0.value, buyRate: $0.value) }
                completion(nil, currencyData, allCurrenciesData)
            } catch {
                completion(nil, nil, nil)
            }
        }
        firstTask.resume()
        secondTask.resume()
    }
}
