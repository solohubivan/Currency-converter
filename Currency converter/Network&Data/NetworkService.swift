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

    func getCurrencyData(completion: @escaping CurrencyDataCompletion) {
        let session = URLSession.shared
        let allCurrenciesURL = URL(string: "https://v6.exchangerate-api.com/v6/\(apiKey)/latest/USD")!
        let defaultCurrenciesURL = URL(string: "https://api.privatbank.ua/p24api/pubinfo?json&exchange&coursid=5")!

        let firstTask = session.dataTask(with: defaultCurrenciesURL) { (data, _, error) in
            guard error == nil, let data = data else { return }

            do {
                let defaultCurrencies = try JSONDecoder().decode([DefaultCurrenciesData].self, from: data)
                let response = CurrencyDataResponse(defaultCurrenciesData: defaultCurrencies,
                                                    currencyData: nil,
                                                    currencyViewModels: nil)
                completion(response)
            } catch {
                completion(CurrencyDataResponse(defaultCurrenciesData: nil, currencyData: nil, currencyViewModels: nil))
            }
        }

        let secondTask = session.dataTask(with: allCurrenciesURL) { (data, _, error) in
            guard error == nil, let data = data else { return }

            do {
                let currencyData = try JSONDecoder().decode(CurrencyData.self, from: data)
                let currencyRates = currencyData.toCurrencyRateArray()
                let allCurrenciesData = currencyRates.map { CurrencyViewModel(name: $0.currencyCode,
                                                                              sellRate: $0.value,
                                                                              buyRate: $0.value)
                }
                let response = CurrencyDataResponse(defaultCurrenciesData: nil,
                                                    currencyData: currencyData,
                                                    currencyViewModels: allCurrenciesData)
                completion(response)
            } catch {
                completion(CurrencyDataResponse(defaultCurrenciesData: nil, currencyData: nil, currencyViewModels: nil))
            }
        }
        firstTask.resume()
        secondTask.resume()
    }

    func getExchangeRates(forDate date: String, completion: @escaping (ExchangeRatesData?) -> Void) {
        let url = URL(string: "https://api.privatbank.ua/p24api/exchange_rates?json&date=\(date)")!
        let session = URLSession.shared

        let task = session.dataTask(with: url) { (data, _, error) in
            guard error == nil, let data = data else {
                completion(nil)
                return
            }

            do {
                let exchangeRatesData = try JSONDecoder().decode(ExchangeRatesData.self, from: data)
                completion(exchangeRatesData)
            } catch {
                completion(nil)
            }
        }
        task.resume()
    }
}
