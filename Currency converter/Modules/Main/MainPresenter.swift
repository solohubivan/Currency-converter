//
//  MainPresenter.swift
//  Currency converter
//
//  Created by Ivan Solohub on 01.10.2023.
//

import Foundation
import UIKit

struct CurrencyViewModel: Codable {
    var name: String
    var sellRate: Double
    var buyRate: Double
    var calculatedResult: Double?
}

protocol MainVCPresenterProtocol: AnyObject {
    func getCurrencyData(offlineMode: Bool)
    func configureLastUpdatedLabel() -> String
    func getActiveCurrencies() -> [CurrencyViewModel]
    func getAllCurrenciesData() -> [CurrencyViewModel]
    func updateCurrencyValues(inputValue: Double, atIndex inputIndex: Int)
    func setConvertingMode(_ mode: ConvertingMode)
    func recalculateValuesForAllCurrencies()
    func createShareText (currencyNames: [String], currencyValues: [Double]) -> String
    func addCurrency(_ currencyCode: String)
    func isInputValid(input: String) -> Bool
    func getActiveCurrenciesCount() -> Int
}

class MainPresenter: MainVCPresenterProtocol {

    private var currencyData = CurrencyData()
    private var defaultCurrenciesData = DefaultCurrenciesData()

    private weak var view: MainViewProtocol?

    private var allCurrenciesData: [CurrencyViewModel] = []
    private var activeCurrencies: [CurrencyViewModel] = []

    private var convertingMode: ConvertingMode = .sell

    init(view: MainViewProtocol) {
        self.view = view
    }

    // MARK: - Public methods

    func getActiveCurrenciesCount() -> Int {
        return activeCurrencies.count
    }

    func isInputValid(input: String) -> Bool {
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
        let isCharactersValid = input.rangeOfCharacter(from: allowedCharacters.inverted) == nil
        let isLengthValid = input.count <= Constants.inputMaxCount
        let dotCount = input.filter { $0 == "." }.count
        return isCharactersValid && isLengthValid && dotCount <= Constants.oneDot
    }

    func addCurrency(_ currencyCode: String) {
        guard !activeCurrencies.contains(where: { $0.name == currencyCode }) else { return }
        activeCurrencies.append(allCurrenciesData.first(where: { $0.name == currencyCode })!)
        recalculateValuesForAllCurrencies()
        view?.updateTableHeight()
        view?.reloadDataCurrencyInfoTable()
    }

    func getAllCurrenciesData() -> [CurrencyViewModel] {
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

    func getActiveCurrencies() -> [CurrencyViewModel] {
        return activeCurrencies
    }

    func updateCurrencyValues(inputValue: Double, atIndex inputIndex: Int) {
        guard inputIndex >= .zero && inputIndex < activeCurrencies.count else { return }

        let inputCurrency = activeCurrencies[inputIndex]
        let baseRate = convertingMode == .sell ? inputCurrency.sellRate : inputCurrency.buyRate

        let valueInBaseCurrency = inputValue / baseRate

        for currencyIndex in .zero..<activeCurrencies.count {
            let targetCurrency = activeCurrencies[currencyIndex]
            let targetRate = convertingMode == .sell ? targetCurrency.sellRate : targetCurrency.buyRate

            let convertedValue = valueInBaseCurrency * targetRate
            activeCurrencies[currencyIndex].calculatedResult = convertedValue
        }
        view?.reloadDataCurrencyInfoTable()
    }

    func getCurrencyData(offlineMode: Bool) {
        if offlineMode {
            self.activeCurrencies = UserDefaultsManager.shared.loadBaseCurrencies() ?? []
            self.allCurrenciesData = UserDefaultsManager.shared.loadAllCurrenciesData() ?? []
            self.view?.reloadDataCurrencyInfoTable()
            self.view?.updateUI(with: self.currencyData)
        } else {
            NetworkService.shared.getCurrencyData { [weak self] defaultCurrencies, currencyData, allCurrenciesData in
                DispatchQueue.main.async {
                    if let defaultCurrencies = defaultCurrencies {
                        self?.activeCurrencies = self?.convertCurrenciesToUSD(currencies: defaultCurrencies) ?? []
                        UserDefaultsManager.shared.saveBaseCurrencies(self!.activeCurrencies)
                    }

                    if let allCurrenciesData = allCurrenciesData {
                        self?.allCurrenciesData = allCurrenciesData
                        UserDefaultsManager.shared.saveAllCurrenciesData(allCurrenciesData)
                    }

                    if let currencyData = currencyData {
                        self?.currencyData = currencyData
                        self?.view?.updateUI(with: currencyData)
                    }

                    self?.view?.reloadDataCurrencyInfoTable()
                }
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

    // MARK: - Private Methods

    private func convertCurrenciesToUSD(currencies: [DefaultCurrenciesData]) -> [CurrencyViewModel] {
        guard let usdCurrency = currencies.first(where: { $0.ccy == Constants.baseCurrencyUSD }),
              let usdBuyRate = Double(usdCurrency.buy),
              let usdSellRate = Double(usdCurrency.sale) else {
            return []
        }

        var convertedCurrencies: [CurrencyViewModel] = []

        convertedCurrencies.append(CurrencyViewModel(name: Constants.baseCurrencyUAH, sellRate: usdSellRate, buyRate: usdBuyRate))

        convertedCurrencies.append(CurrencyViewModel(name: Constants.baseCurrencyUSD, sellRate: Constants.baseCurrencyValue, buyRate: Constants.baseCurrencyValue))

        if let eurCurrency = currencies.first(where: { $0.ccy == Constants.baseCurrencyEUR }),
           let eurBuyRate = Double(eurCurrency.buy),
           let eurSellRate = Double(eurCurrency.sale) {
            let eurToUsdBuyRate = usdBuyRate / eurBuyRate
            let eurToUsdSellRate = usdSellRate / eurSellRate
            convertedCurrencies.append(CurrencyViewModel(name: Constants.baseCurrencyEUR, sellRate: eurToUsdSellRate, buyRate: eurToUsdBuyRate))
        }
        return convertedCurrencies
    }
}

extension MainPresenter {
    private enum Constants {
        static let baseCurrencyValue: Double = 1.0
        static let baseCurrencyUAH: String = "UAH"
        static let baseCurrencyUSD: String = "USD"
        static let baseCurrencyEUR: String = "EUR"

        static let inputMaxCount: Int = 12
        static let oneDot: Int = 1
    }
}
