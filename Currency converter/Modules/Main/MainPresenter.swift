//
//  MainPresenter.swift
//  Currency converter
//
//  Created by Ivan Solohub on 01.10.2023.
//

import Foundation
import UIKit


struct CurrencyDataModel {
    var name: String
    var sellRate: Double
    var buyRate: Double
    var calculatedResult: Double?
}


protocol MainVCPresenterProtocol: AnyObject {
    func getCurrencyData()
    func configureLastUpdatedLabel() -> String
    func getActiveCurrencies() -> [CurrencyDataModel]
    func getAllCurrenciesData() -> [CurrencyDataModel]
    func updateCurrencyValues(inputValue: Double, atIndex inputIndex: Int)
    func setConvertingMode(_ mode: ConvertingMode)
    func recalculateValuesForAllCurrencies()
    func createShareText (currencyNames: [String], currencyValues: [Double]) -> String
    func addCurrency(_ currencyCode: String)
}


class MainPresenter: MainVCPresenterProtocol {
    
    private var currencyData = CurrencyData()
    private var defaultCurrenciesData = DefaultCurrenciesData()
    
    private weak var view: MainViewProtocol?
    
    private var allCurrenciesData: [CurrencyDataModel] = []
    private var activeCurrencies: [CurrencyDataModel] = []

    private var convertingMode: ConvertingMode = .sell
    
    
    init(view: MainViewProtocol) {
        self.view = view
    }
    
    //MARK: - Public methods
/*
    func updateValueForNewCurrency() {
        guard let baseCurrency = activeCurrencies.first(where: { $0.calculatedResult != nil }) else { return }

        let baseValue = baseCurrency.calculatedResult!
        let baseRate = convertingMode == .sell ? baseCurrency.sellRate : baseCurrency.buyRate

        for index in 0..<activeCurrencies.count {
            let rate = convertingMode == .sell ? activeCurrencies[index].sellRate : activeCurrencies[index].buyRate
            activeCurrencies[index].calculatedResult = (baseValue * baseRate) / rate
        }
    }
  */
    
    func addCurrency(_ currencyCode: String) {
        guard !activeCurrencies.contains(where: { $0.name == currencyCode }) else { return }
        activeCurrencies.append(allCurrenciesData.first(where: { $0.name == currencyCode })!)

        //method to create value for new currencies
//        updateValueForNewCurrency()
        recalculateValuesForAllCurrencies()
        
        view?.updateTableHeight()
        view?.reloadDataCurrencyInfoTable()
        
        print(activeCurrencies)
    }
    
    func getAllCurrenciesData() -> [CurrencyDataModel] {
        return allCurrenciesData
    }
    
    func createShareText (currencyNames: [String], currencyValues: [Double]) -> String {
        let combinedData = zip(currencyNames, currencyValues)
        let formattedStrings = combinedData.map { (name, value) in "\(name): \(String(format: "%.2f", value))\n"}
        return formattedStrings.joined()
    }
    
    func recalculateValuesForAllCurrencies() {
        for (index, currency) in activeCurrencies.enumerated() {
            if let currentValue = currency.calculatedResult {
                   updateCurrencyValues(inputValue: currentValue, atIndex: index)
            }
        }
    }
    
    func setConvertingMode(_ mode: ConvertingMode) {
        convertingMode = mode
        recalculateValuesForAllCurrencies()
    }
    
    func getActiveCurrencies() -> [CurrencyDataModel] {
        return activeCurrencies
    }
    
    func updateCurrencyValues(inputValue: Double, atIndex inputIndex: Int) {
        guard inputIndex >= 0 && inputIndex < activeCurrencies.count else { return }
        
        let rates = convertingMode == .sell ? activeCurrencies.map { $0.sellRate } : activeCurrencies.map { $0.buyRate }
        var resultValues: [Double] = []
        
        for i in 0..<rates.count {
            if i == inputIndex {
                resultValues.append(inputValue)
            } else {
                let valueInUSD = inputValue * rates[inputIndex]
                let convertedValue = valueInUSD / rates[i]
                resultValues.append(convertedValue)
            }
        }
 //       print(resultValues)
        for (index, value) in resultValues.enumerated() {
            activeCurrencies[index].calculatedResult = value
        }
        view?.reloadDataCurrencyInfoTable()
    }

    func getCurrencyData() {
        let session = URLSession.shared
        let allCurrenciesURL = URL(string: "https://v6.exchangerate-api.com/v6/82627c0b81b426a2b8186f4d/latest/USD")!
        let defaultCurrenciesURL = URL(string: "https://api.privatbank.ua/p24api/pubinfo?json&exchange&coursid=5")!
        
        let firstTask = session.dataTask(with: defaultCurrenciesURL) { (data, response, error) in
            guard error == nil else { return }
            
            do {
                let defaultCurrencies = try JSONDecoder().decode([DefaultCurrenciesData].self, from: data!)
                    
                self.activeCurrencies = self.convertCurrenciesToUSD(currencies: defaultCurrencies)

 //               print(self.activeCurrencies)
            } catch {
 //               print("Error with getting data: \(error)")
            }
        }
        
        let secondTask = session.dataTask(with: allCurrenciesURL) { (data, response, error) in
            guard error == nil else { return }
            
            do {
                self.currencyData = try JSONDecoder().decode(CurrencyData.self, from: data!)
                let currencyRates = self.currencyData.toCurrencyRateArray()
                
                
                self.allCurrenciesData = currencyRates.map { CurrencyDataModel(name: $0.currencyCode, sellRate: $0.value, buyRate: $0.value) }

                    DispatchQueue.main.async {
                        self.view?.updateUI(with: self.currencyData)
                        self.view?.reloadDataCurrencyInfoTable()
                    }
 //               print(self.allCurrenciesData)
            } catch {
 //               print("Error with getting data: \(error)")
            }
        }
        firstTask.resume()
        secondTask.resume()
    }

    func configureLastUpdatedLabel() -> String {
        let dateInfo = currencyData.timeLastUpdateUtc
        var result = ""
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "E, d MMM yyy HH:mm:ss Z"
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd MMM yyyy h:mm a"
        
        if let date = inputFormatter.date(from: dateInfo) {
            result = "\(R.string.localizable.last_updated()) \n" + outputFormatter.string(from: date)
        }
        return result
    }

    //MARK: - Private Methods
    
    private func convertCurrenciesToUSD(currencies: [DefaultCurrenciesData]) -> [CurrencyDataModel] {
        guard let usdData = currencies.first(where: { $0.ccy == "USD" }),
              let usdSellRate = Double(usdData.sale),
              let usdBuyRate = Double(usdData.buy) else { return [] }
        
        var convertedCurrencies: [CurrencyDataModel] = []
        convertedCurrencies.append(CurrencyDataModel(name: "UAH", sellRate: 1 / usdSellRate, buyRate: 1 / usdBuyRate))
        
        for currency in currencies {
            if currency.ccy == "USD" {
                convertedCurrencies.append(CurrencyDataModel(name: "USD", sellRate: 1.0, buyRate: 1.0))
            } else {
                let sellRate = (Double(currency.sale) ?? 0.0) / usdSellRate
                let buyRate = (Double(currency.buy) ?? 0.0) / usdBuyRate
                convertedCurrencies.append(CurrencyDataModel(name: currency.ccy, sellRate: sellRate, buyRate: buyRate))
            }
        }
        return convertedCurrencies
    }
}

extension MainPresenter {
    private enum Constants {
        
    }
}
