//
//  MainPresenter.swift
//  Currency converter
//
//  Created by Ivan Solohub on 01.10.2023.
//

import Foundation
import UIKit


protocol MainVCPresenterProtocol: AnyObject {
    func getCurrenciesDataValues()
    func configureLastUpdatedLabel() -> String
    func updateCalculatedCurencyValue(with newValue: String?, at index: Int)
    func getActiveCurrenciesForTable() -> [String]
    func getDefaultCurrencies() -> [String]
    func getCurrenciesListData() -> [String]
    func addCurrency(_ currency: String)
    func updatePriceValues(isSellMode: Bool)
    func createShareText (currencyNames: [String], currencyValues: [Double]) -> String
    func getConvertedResults() -> [Double]
    func getCurrenciesDataValues(offlineMode: Bool)
}


class MainPresenter: MainVCPresenterProtocol {
    
    private var currencyData = CurrencyData()
    private var defaultCurrenciesData = DefaultCurrenciesData()
    
    private weak var view: MainViewProtocol?

    private var defaultCurrenciesNames = [Constants.currencyNameUAH, Constants.currencyNameUSD, Constants.currencyNameEUR]
    private var currencies = [Constants.currencyNameUAH, Constants.currencyNameUSD, Constants.currencyNameEUR]
    private var currenciesListData: [String] = []
    
    private var purchasePriceDefaultCurrencies: [Double] = []
    private var salePriceDefaultCurrensies: [Double] = []
    private var otherAllCurrensiesPriceValues: [Double] = []
    private var defaultCurrenciesPriceValues: [Double] = []
    
    private var currencyPriceValues: [Double] = []
    private var convertedResult: [Double] = []
    
    private var inputedTFValue: Double?
    
    
    init(view: MainViewProtocol) {
        self.view = view
    }
    
    //MARK: - Public methods
    func getCurrenciesValues() -> [Double] {
        return currencyPriceValues
    }
    
    func getConvertedResults() -> [Double] {
        return convertedResult
    }
    
    func getDefaultCurrencies() -> [String] {
        return defaultCurrenciesNames
    }
    
    func getActiveCurrenciesForTable() -> [String] {
        return currencies
    }
    
    func getCurrenciesListData() -> [String] {
        return currenciesListData
    }
    
    func getCurrenciesDataValues() {
        getCurrencyData()
    }
    
    func createShareText (currencyNames: [String], currencyValues: [Double]) -> String {
        let combinedData = zip(currencyNames, currencyValues)
        let formattedStrings = combinedData.map { (name, value) in "\(name): \(value)\n" }
        return formattedStrings.joined()
    }
    
    func updatePriceValues(isSellMode: Bool) {
        currencyPriceValues = isSellMode ? salePriceDefaultCurrensies : purchasePriceDefaultCurrencies
        defaultCurrenciesPriceValues = isSellMode ? salePriceDefaultCurrensies : purchasePriceDefaultCurrencies
        updateCurrencyValuesForNewCurrencies()
    }

    func addCurrency(_ currency: String) {
        guard !currencies.contains(currency) else { return }
        currencies.append(currency)
        updateCurrencyValuesForNewCurrencies()
        view?.updateTableHeight()
        view?.reloadDataCurrencyInfoTable()
    }
    
    func updateCalculatedCurencyValue(with newValue: String?, at index: Int) {
        guard let newValue = newValue, let inputedValue = Double(newValue) else { return }
        
        var resultValues: [Double] = currencyPriceValues

        guard index >= .zero && index < resultValues.count else { return }
            for i in .zero..<resultValues.count {
                if i == index {
                    resultValues[i] = inputedValue
                } else {
                    resultValues[i] = inputedValue / currencyPriceValues[index] * currencyPriceValues[i]
                }
            }
        convertedResult = []
        convertedResult = resultValues
        convertedResult = convertedResult.map { value in
            return Double(String(format: "%.2f", value)) ?? Constants.defaultCurrencyPriceValue
            }
  //      print(currencyPriceValues)
        inputedTFValue = inputedValue

        view?.reloadDataCurrencyInfoTable()
    }

    func configureLastUpdatedLabel() -> String {
        let dateInfo = (currencyData.time_last_update_utc)
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
    
    func getCurrenciesDataValues(offlineMode: Bool = false) {
        if offlineMode {
            loadCurrenciesDataFromUserDefaults()
        } else {
            getCurrencyData()
        }
    }
    
    

    //MARK: - Private methods
    
    private func getCurrencyData() {
        let session = URLSession.shared
        let allCurrenciesURL = URL(string: "https://v6.exchangerate-api.com/v6/82627c0b81b426a2b8186f4d/latest/USD")!
        let defaultCurrenciesURL = URL(string: "https://api.privatbank.ua/p24api/pubinfo?json&exchange&coursid=5")!
        
        
        let firstTask = session.dataTask(with: defaultCurrenciesURL) { (data, response, error) in
            guard error == nil else { return }
            
            do {
                
                let defaultCurrenciesData = try JSONDecoder().decode([DefaultCurrenciesData].self, from: data!)
                
                self.purchasePriceDefaultCurrencies = self.convertCurrenciesToUSD(defaultCurrenciesData, isBuyMode: true)
                self.salePriceDefaultCurrensies = self.convertCurrenciesToUSD(defaultCurrenciesData, isBuyMode: false)
               

                self.defaultCurrenciesPriceValues = self.salePriceDefaultCurrensies
                self.currencyPriceValues = self.defaultCurrenciesPriceValues
                
            } catch {

            }
        }
            
        let secondTask = session.dataTask(with: allCurrenciesURL) { (data, response, error) in
            guard error == nil else { return }
            
            do {
                self.currencyData = try JSONDecoder().decode(CurrencyData.self, from: data!)
                
                self.currenciesListData = Array(self.currencyData.conversion_rates.keys)
                self.otherAllCurrensiesPriceValues = Array(self.currencyData.conversion_rates.values)
                
                
                DispatchQueue.main.async {
                    self.view?.updateUI(with: self.currencyData)
                }
                
                self.saveCurrenciesDataToUserDefalts()
                
            } catch {

            }
        }
        firstTask.resume()
        secondTask.resume()
    }
    
    private func saveCurrenciesDataToUserDefalts() {
        UserDefaults.standard.set(currencies, forKey: "currencies")
        UserDefaults.standard.set(currencyPriceValues, forKey: "currencyPriceValues")
        UserDefaults.standard.set(purchasePriceDefaultCurrencies, forKey: "purchasePriceDefaultCurrencies")
        UserDefaults.standard.set(salePriceDefaultCurrensies, forKey: "salePriceDefaultCurrensies")
        UserDefaults.standard.set(currenciesListData, forKey: "currenciesListData")
        UserDefaults.standard.set(otherAllCurrensiesPriceValues, forKey: "otherAllCurrensiesPriceValues")

        UserDefaults.standard.set(currencyData.time_last_update_utc, forKey: "lastUpdateDate")
    }
    
    private func loadCurrenciesDataFromUserDefaults() {
        if let savedCurrencies = UserDefaults.standard.array(forKey: "currencies") as? [String],
           let savedCurrenciesListData = UserDefaults.standard.array(forKey: "currenciesListData") as? [String],
           let savedCurrencyPriceValues = UserDefaults.standard.array(forKey: "currencyPriceValues") as? [Double],
           let savedPurchasePriceDefaultCurrencies = UserDefaults.standard.array(forKey: "purchasePriceDefaultCurrencies") as? [Double],
           let savedSalePriceDefaultCurrensies = UserDefaults.standard.array(forKey: "salePriceDefaultCurrensies") as? [Double],
           let savedOtherAllCurrensiesPriceValues = UserDefaults.standard.array(forKey: "otherAllCurrensiesPriceValues") as? [Double],
           !savedCurrencies.isEmpty,
           !savedCurrencyPriceValues.isEmpty {
            currencies = savedCurrencies
            currencyPriceValues = savedCurrencyPriceValues
            purchasePriceDefaultCurrencies = savedPurchasePriceDefaultCurrencies
            salePriceDefaultCurrensies = savedSalePriceDefaultCurrensies
            currenciesListData = savedCurrenciesListData
            otherAllCurrensiesPriceValues = savedOtherAllCurrensiesPriceValues

            view?.reloadDataCurrencyInfoTable()
        } else {
            view?.showNoDataAlert()
        }
        
        if let lastUpdateDate = UserDefaults.standard.string(forKey: "lastUpdateDate") {
                currencyData.time_last_update_utc = lastUpdateDate
                DispatchQueue.main.async {
                    self.view?.updateUI(with: self.currencyData)
                }
            }
    }
    
    private func updateCurrencyValuesForNewCurrencies() {

        var newCurrencyValues: [Double] = defaultCurrenciesPriceValues

        for currency in currencies {
            if !defaultCurrenciesNames.contains(currency) {
                if let index = currenciesListData.firstIndex(of: currency) {
                    if index < otherAllCurrensiesPriceValues.count {
                        let currencyValue = otherAllCurrensiesPriceValues[index]
                        newCurrencyValues.append(currencyValue)
                    }
                }
            }
        }
        currencyPriceValues = newCurrencyValues
        
        
        var resultValues: [Double] = currencyPriceValues

        for i in .zero..<resultValues.count {
                resultValues[i] = (inputedTFValue ?? Constants.defaultInputedValue) * currencyPriceValues[i]
            }
            convertedResult = resultValues
            convertedResult = convertedResult.map { value in
                return Double(String(format: "%.2f", value)) ?? Constants.defaultCurrencyPriceValue
            }
    }

    private func convertCurrenciesToUSD(_ data: [DefaultCurrenciesData], isBuyMode: Bool) -> [Double] {
        var usdPrice = Constants.defaultCurrencyPriceValue
        var eurPrice = Constants.defaultCurrencyPriceValue
            
        if let usdCurrencyData = data.first(where: { $0.ccy == Constants.currencyNameUSD }) {
                if let price = isBuyMode ? Double(usdCurrencyData.buy) : Double(usdCurrencyData.sale) {
                    usdPrice = price
                }
            }
            
        if let eurCurrencyData = data.first(where: { $0.ccy == Constants.currencyNameEUR }) {
                if let price = isBuyMode ? Double(eurCurrencyData.buy) : Double(eurCurrencyData.sale) {
                    eurPrice = price
                }
            }
            
            var alignedCurrencies = [usdPrice]
            
            for currency in self.currencies {
                if currency == Constants.currencyNameUSD {
                    alignedCurrencies.append(Constants.defaultInputedValue)
                } else if currency == Constants.currencyNameEUR {
                    alignedCurrencies.append(usdPrice / eurPrice)
                } else if let currencyData = data.first(where: { $0.ccy == currency }) {
                    if let price = isBuyMode ? Double(currencyData.buy) : Double(currencyData.sale) {
                        alignedCurrencies.append(price / usdPrice)
                    }
                }
            }
            return alignedCurrencies
    }
    
}

extension MainPresenter {
    private enum Constants {
        static let defaultCurrencyPriceValue: Double = 0.0
        static let defaultInputedValue: Double = 1.0
        
        static let currencyNameUSD: String = "USD"
        static let currencyNameEUR: String = "EUR"
        static let currencyNameUAH: String = "UAH"
    }
}
