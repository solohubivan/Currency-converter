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
    
    func addCurrency(_ currencyCode: String) {
        guard !activeCurrencies.contains(where: { $0.name == currencyCode }) else { return }
        activeCurrencies.append(allCurrenciesData.first(where: { $0.name == currencyCode })!)
        recalculateValuesForAllCurrencies()
        view?.updateTableHeight()
        view?.reloadDataCurrencyInfoTable()
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
        
        let inputCurrency = activeCurrencies[inputIndex]
        let baseRate = convertingMode == .sell ? inputCurrency.sellRate : inputCurrency.buyRate

        let valueInBaseCurrency = inputValue / baseRate

        for i in 0..<activeCurrencies.count {
            let targetCurrency = activeCurrencies[i]
            let targetRate = convertingMode == .sell ? targetCurrency.sellRate : targetCurrency.buyRate

            let convertedValue = valueInBaseCurrency * targetRate
            activeCurrencies[i].calculatedResult = convertedValue
        }
        view?.reloadDataCurrencyInfoTable()
    }
    
    func getCurrencyData() {
        NetworkService.shared.getCurrencyData { [weak self] defaultCurrencies, currencyData, allCurrenciesData in
            DispatchQueue.main.async {
                if let defaultCurrencies = defaultCurrencies {
                    self?.activeCurrencies = self?.convertCurrenciesToUSD(currencies: defaultCurrencies) ?? []
                }

                if let allCurrenciesData = allCurrenciesData {
                    self?.allCurrenciesData = allCurrenciesData
                }
                    
                if let currencyData = currencyData {
                    self?.currencyData = currencyData
                    self?.view?.updateUI(with: currencyData)
                }

                self?.view?.reloadDataCurrencyInfoTable()
            }
        }
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
        guard let usdCurrency = currencies.first(where: { $0.ccy == "USD" }),
              let usdBuyRate = Double(usdCurrency.buy),
              let usdSellRate = Double(usdCurrency.sale) else {
            return []
        }

        var convertedCurrencies: [CurrencyDataModel] = []

        convertedCurrencies.append(CurrencyDataModel(name: "UAH", sellRate: usdSellRate, buyRate: usdBuyRate))

        convertedCurrencies.append(CurrencyDataModel(name: "USD", sellRate: 1.0, buyRate: 1.0))

        if let eurCurrency = currencies.first(where: { $0.ccy == "EUR" }),
           let eurBuyRate = Double(eurCurrency.buy),
           let eurSellRate = Double(eurCurrency.sale) {
            let eurToUsdBuyRate = usdBuyRate / eurBuyRate
            let eurToUsdSellRate = usdSellRate / eurSellRate
            convertedCurrencies.append(CurrencyDataModel(name: "EUR", sellRate: eurToUsdSellRate, buyRate: eurToUsdBuyRate))
        }
        return convertedCurrencies
    }
}

extension MainPresenter {
    private enum Constants {
        
    }
}
