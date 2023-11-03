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
    func createTitleNameForCurrencyLabel(text: String) -> NSAttributedString
    func updateCalculatedCurencyValue(with newValue: String?, at index: Int)
    func getActiveCurrenciesForTable() -> [String]
    func getDefaultCurrencies() -> [String]
    func getCurrenciesListData() -> [String]
    func addCurrency(_ currency: String)
    func updatePriceValues(isSellMode: Bool)
    func createShareText (currencyNames: [String], currencyValues: [Double]) -> String
    func getConvertedResults() -> [Double]
}


class MainPresenter: MainVCPresenterProtocol {
    
    private var currencyData = CurrencyData()
    private var defaultCurrenciesData = DefaultCurrenciesData()
    
    private weak var view: MainViewProtocol?

    private var defaultCurrenciesNames = ["UAH", "USD", "EUR"]
    private var currencies = ["UAH", "USD", "EUR"]
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
        
        var textToShare = ""
        
        for (index, currencyName) in currencyNames.enumerated() {
            if index < currencyValues.count {
                let currencyValue = currencyValues[index]
                let currencyInfo = "\(currencyName): \(currencyValue)"
                
                if !textToShare.isEmpty {
                    textToShare += "\n"
                }
                textToShare += currencyInfo
            }
        }
        return textToShare
    }
    
    func updatePriceValues(isSellMode: Bool) {
        if isSellMode {
            currencyPriceValues = salePriceDefaultCurrensies
            defaultCurrenciesPriceValues = salePriceDefaultCurrensies
            updateCurrencyValuesForNewCurrencies()
        } else {
            currencyPriceValues = purchasePriceDefaultCurrencies
            defaultCurrenciesPriceValues = purchasePriceDefaultCurrencies
            updateCurrencyValuesForNewCurrencies()
        }
    }

    func addCurrency(_ currency: String) {
        guard !currencies.contains(currency) else {
            return
        }
        currencies.append(currency)
        updateCurrencyValuesForNewCurrencies()
        view?.updateTableHeight()
        view?.reloadDataCurrencyInfoTable()
    }
    
    func updateCalculatedCurencyValue(with newValue: String?, at index: Int) {
        guard let newValue = newValue, let inputedValue = Double(newValue) else {
                return
            }
        
        var resultValues: [Double] = currencyPriceValues

        guard index >= .zero && index < resultValues.count else {
                return
            }
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
                return Double(String(format: "%.2f", value)) ?? 0.0
            }
        print(currencyPriceValues)
        inputedTFValue = inputedValue

        view?.reloadDataCurrencyInfoTable()
    }
    
    func createTitleNameForCurrencyLabel(text: String) -> NSAttributedString {
        let chevronImage = R.image.chevronRight()
        
        let attributedString = NSMutableAttributedString()
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: R.font.latoRegular(size: 14)!,
            .foregroundColor: UIColor.hex003166
        ]
        
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = chevronImage
        
        let imageString = NSAttributedString(attachment: imageAttachment)
        let textString = NSAttributedString(string: text, attributes: textAttributes)
        
        attributedString.append(textString)
        attributedString.append(NSAttributedString(string: String("   ")))
        attributedString.append(imageString)
        
        return attributedString
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

    //MARK: - Private methods
    
    private func getCurrencyData() {
        let session = URLSession.shared
        let allCurrenciesURL = URL(string: "https://v6.exchangerate-api.com/v6/82627c0b81b426a2b8186f4d/latest/USD")!
        let defaultCurrenciesURL = URL(string: "https://api.privatbank.ua/p24api/pubinfo?json&exchange&coursid=5")!
        
        
        let firstTask = session.dataTask(with: defaultCurrenciesURL) { (data, response, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            do {
                
                let defaultCurrenciesData = try JSONDecoder().decode([DefaultCurrenciesData].self, from: data!)
                
                self.purchasePriceDefaultCurrencies = self.convertCurrenciesToUSD(defaultCurrenciesData, isBuyMode: true)
                self.salePriceDefaultCurrensies = self.convertCurrenciesToUSD(defaultCurrenciesData, isBuyMode: false)
               

                self.defaultCurrenciesPriceValues = self.salePriceDefaultCurrensies
                self.currencyPriceValues = self.defaultCurrenciesPriceValues
                
            } catch {
                print(error.localizedDescription)
            }
        }
            
        let secondTask = session.dataTask(with: allCurrenciesURL) { (data, response, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            do {
                self.currencyData = try JSONDecoder().decode(CurrencyData.self, from: data!)
                
                self.currenciesListData = Array(self.currencyData.conversion_rates.keys)
                self.otherAllCurrensiesPriceValues = Array(self.currencyData.conversion_rates.values)
                
                
                DispatchQueue.main.async {
                    self.view?.updateUI(with: self.currencyData)
                }
                
            } catch {
                print(error.localizedDescription)
            }
        }
        firstTask.resume()
        secondTask.resume()
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

            for i in 0..<resultValues.count {
                resultValues[i] = (inputedTFValue ?? 1.0) * currencyPriceValues[i]
            }
            convertedResult = resultValues
            convertedResult = convertedResult.map { value in
                return Double(String(format: "%.2f", value)) ?? 0.0
            }
    }

    private func convertCurrenciesToUSD(_ data: [DefaultCurrenciesData], isBuyMode: Bool) -> [Double] {
        var usdPrice = 0.0
        var eurPrice = 0.0
            
            if let usdCurrencyData = data.first(where: { $0.ccy == "USD" }) {
                if let price = isBuyMode ? Double(usdCurrencyData.buy) : Double(usdCurrencyData.sale) {
                    usdPrice = price
                }
            }
            
            if let eurCurrencyData = data.first(where: { $0.ccy == "EUR" }) {
                if let price = isBuyMode ? Double(eurCurrencyData.buy) : Double(eurCurrencyData.sale) {
                    eurPrice = price
                }
            }
            
            var alignedCurrencies = [usdPrice]
            
            for currency in self.currencies {
                if currency == "USD" {
                    alignedCurrencies.append(1.0)
                } else if currency == "EUR" {
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
        
    }
}
