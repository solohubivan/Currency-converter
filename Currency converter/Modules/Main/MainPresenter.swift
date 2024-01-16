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
// sourcery: AutoMockable
protocol PresenterProptocolMock: AnyObject {
    var activeCurrencies: [CurrencyViewModel] { get set }
    func getActiveCurrenciesCount() -> Int
    func removeActiveCurrencies(at index: Int)
}

protocol MainVCPresenterProtocol: AnyObject {
    func getCurrencyData(offlineMode: Bool)
    func configureLastUpdatedLabel() -> String
    func getActiveCurrencies() -> [CurrencyViewModel]
    func getAllCurrenciesData() -> [CurrencyViewModel]
    func updateCurrencyValues(inputValue: String, atIndex inputIndex: Int)
    func setConvertingMode(_ mode: ConvertingMode)
    func recalculateValuesForAllCurrencies()
    func createShareText (currencyNames: [String], currencyValues: [Double]) -> String
    func addCurrency(_ currencyCode: String)
    func getActiveCurrenciesCount() -> Int
    func removeActiveCurrencies(at index: Int)
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

    func removeActiveCurrencies(at index: Int) {
        guard index >= .zero && index < activeCurrencies.count else { return }
        activeCurrencies.remove(at: index)
        view?.updateTableHeight()
        view?.reloadDataCurrencyInfoTable()
    }

    func getActiveCurrenciesCount() -> Int {
        return activeCurrencies.count
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
                let currentValueString = String(currentValue)
                updateCurrencyValues(inputValue: currentValueString, atIndex: index)
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

    func updateCurrencyValues(inputValue: String, atIndex inputIndex: Int) {
        guard inputIndex >= .zero && inputIndex < activeCurrencies.count,
            let newDoubleValue = Double(inputValue) else { return }

        let inputCurrency = activeCurrencies[inputIndex]
        let baseRate = convertingMode == .sell ? inputCurrency.sellRate : inputCurrency.buyRate

        let valueInBaseCurrency = newDoubleValue / baseRate

        for currencyIndex in .zero..<activeCurrencies.count {
            let targetCurrency = activeCurrencies[currencyIndex]
            let targetRate = convertingMode == .sell ? targetCurrency.sellRate : targetCurrency.buyRate

            let convertedValue = valueInBaseCurrency * targetRate
            activeCurrencies[currencyIndex].calculatedResult = convertedValue
        }
        view?.reloadDataCurrencyInfoTable()
    }

    public func getCurrencyData(offlineMode: Bool) {
        if offlineMode {
            self.activeCurrencies = UserDefaultsManager.shared.loadBaseCurrencies() ?? []
            self.allCurrenciesData = UserDefaultsManager.shared.loadAllCurrenciesData() ?? []
            self.view?.reloadDataCurrencyInfoTable()
            self.view?.updateUI(with: self.currencyData)
        } else {
            NetworkService.shared.getCurrencyData { [weak self]  response in
                DispatchQueue.main.async {
                    if let defaultCurrencies = response.defaultCurrenciesData {
                        self?.activeCurrencies = self?.convertCurrenciesToUSD(currencies: defaultCurrencies) ?? []
                        UserDefaultsManager.shared.saveBaseCurrencies(self!.activeCurrencies)
                    }

                    if let allCurrenciesData = response.currencyViewModels {
                        self?.allCurrenciesData = allCurrenciesData
                        UserDefaultsManager.shared.saveAllCurrenciesData(allCurrenciesData)
                    }

                    if let currencyData = response.currencyData {
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
              let eurCurrency = currencies.first(where: { $0.ccy == Constants.baseCurrencyEUR }),
              let usdBuyRate = Double(usdCurrency.buy),
              let usdSellRate = Double(usdCurrency.sale),
              let eurBuyRate = Double(eurCurrency.buy),
              let eurSellRate = Double(eurCurrency.sale)
        else {
            return []
        }

        let currencyUahModel = CurrencyViewModel(name: Constants.baseCurrencyUAH,
                                                 sellRate: usdSellRate,
                                                 buyRate: usdBuyRate)
        let currencyUsdModel = CurrencyViewModel(name: Constants.baseCurrencyUSD,
                                                 sellRate: Constants.baseCurrencyValue,
                                                 buyRate: Constants.baseCurrencyValue)
        let currencyEurModel = CurrencyViewModel(name: Constants.baseCurrencyEUR,
                                                 sellRate: usdSellRate / eurSellRate,
                                                 buyRate: usdBuyRate / eurBuyRate)

        return [currencyUahModel, currencyUsdModel, currencyEurModel]
    }
}

extension MainPresenter {
    private enum Constants {
        static let baseCurrencyValue: Double = 1.0
        static let baseCurrencyUAH: String = "UAH"
        static let baseCurrencyUSD: String = "USD"
        static let baseCurrencyEUR: String = "EUR"
    }
}
