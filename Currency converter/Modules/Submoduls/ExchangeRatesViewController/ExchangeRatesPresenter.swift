//
//  ExchangeRatesPresenter.swift
//  Currency converter
//
//  Created by Ivan Solohub on 03.11.2023.
//

import Foundation
import UIKit


protocol ExchangeRatesPresenterProtocol: AnyObject {
    
    func getCurrencies() -> [String]
    func getData(date: String)
    func configureCellName(forCode code: String) -> String?
    func getSaleRateNB() -> [Double]
    func getPurchaseRateNB() -> [Double]
}

class ExchangeRatesPresenter: ExchangeRatesPresenterProtocol {
    
    private var exchangeRatesData = ExchangeRatesData()
    private weak var view: ExchangeRatesVCProtocol?
    
    private var currencies: [String] = []
    private var saleRateNB: [Double] = []
    private var purchaseRateNB: [Double] = []
    
    init(view: ExchangeRatesVCProtocol) {
        self.view = view
    }
    
    //MARK: - Public Methods
    
    func getPurchaseRateNB() -> [Double] {
        return purchaseRateNB
    }
    
    func getSaleRateNB() -> [Double] {
        return saleRateNB
    }
    
    func getCurrencies() -> [String] {
        return currencies
    }
    
    func configureCellName(forCode code: String) -> String? {
        return currencyDescriptions[code]
    }
    
    func getData(date: String) {
        let session = URLSession.shared
        let url = URL(string: "https://api.privatbank.ua/p24api/exchange_rates?json&date=\(date)")!
        let task = session.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            do {
                
                self.exchangeRatesData = try JSONDecoder().decode(ExchangeRatesData.self, from: data!)
                
                self.currencies = self.exchangeRatesData.exchangeRate.map {
                    $0.currency }
                self.saleRateNB = self.exchangeRatesData.exchangeRate.map { rate in
                    let formattedRate = String(format: "%.2f", rate.saleRateNB)
                    return Double(formattedRate) ?? 0.0 }
                self.purchaseRateNB = self.exchangeRatesData.exchangeRate.map { rate in
                    let formattedRate = String(format: "%.2f", rate.purchaseRateNB)
                    return Double(formattedRate) ?? 0.0 }
                
                DispatchQueue.main.async {
                    self.view?.reloadTable()
                }
                
            } catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
}
