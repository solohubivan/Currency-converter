//
//  ExchangeRatesPresenter.swift
//  Currency converter
//
//  Created by Ivan Solohub on 03.11.2023.
//

import Foundation
import UIKit

struct ExchangeRatesViewModel: Codable {
    var name: String
    var sellRateNB: Double
    var buyRateNB: Double
}

protocol ExchangeRatesPresenterProtocol: AnyObject {
    func createCellName(forCode code: String) -> String?
    func getCurrenciesCount() -> Int
    func getExchangeRates() -> [ExchangeRatesViewModel]
    func fetchDate(date: String)
}

class ExchangeRatesPresenter: ExchangeRatesPresenterProtocol {

    private var exchangeRatesData = ExchangeRatesData()
    private weak var view: ExchangeRatesVCProtocol?

    private var exchangeRates: [ExchangeRatesViewModel] = []

    init(view: ExchangeRatesVCProtocol) {
        self.view = view
    }

    // MARK: - Public Methods

    func fetchDate(date: String) {
        getExchangeRatesData(date: date)
    }

    func getExchangeRates() -> [ExchangeRatesViewModel] {
        return exchangeRates
    }

    func getCurrenciesCount() -> Int {
        return exchangeRates.count
    }

    func createCellName(forCode code: String) -> String? {
        return currencyDescriptions[code]
    }

    // MARK: - Private Methods

    private func getExchangeRatesData(date: String) {
        NetworkService.shared.getExchangeRates(forDate: date) { [weak self] exchangeRatesData in
            guard let self = self, let exchangeRatesData = exchangeRatesData else { return }

            self.exchangeRates = exchangeRatesData.exchangeRate.map { rate in
                let formattedSellRateNB = Double(String(format: "%.2f", rate.saleRateNB)) ?? .zero
                let formattedPurchaseRateNB = Double(String(format: "%.2f", rate.purchaseRateNB)) ?? .zero

                return ExchangeRatesViewModel(
                    name: rate.currency,
                    sellRateNB: formattedSellRateNB,
                    buyRateNB: formattedPurchaseRateNB
                )
            }

            DispatchQueue.main.async {
                self.view?.reloadTable()
            }
        }
    }
}
