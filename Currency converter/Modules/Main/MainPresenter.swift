//
//  MainPresenter.swift
//  Currency converter
//
//  Created by Ivan Solohub on 01.10.2023.
//

import Foundation
import UIKit


protocol MainVCPresenterProtocol: AnyObject {
    func getCurrencyData()
    func createTitleNameForButton(text: String, textSize: CGFloat) -> NSAttributedString
    func configureLastUpdatedLabel() -> String
    func createTitleNameForCurrencyLabel(text: String) -> NSAttributedString
    func updateCalculatedCurencyValue(with newValue: String?, at index: Int)
    func getCurrenciesListData() -> [String]
}


class MainPresenter: MainVCPresenterProtocol {
    
    private var currencyData = CurrencyData()
    private weak var view: MainViewProtocol?

    
    private var currencies = ["UAH", "USD", "EUR"]
    private var currencyValues: [Double] = []
    private var convertedResult: [Double] = []
    
    private var currenciesListData: [String] = []

    
    init(view: MainViewProtocol) {
        self.view = view
    }
    
    func getCurrenciesListData() -> [String] {
        return currenciesListData
    }
    
    func updateCalculatedCurencyValue(with newValue: String?, at index: Int) {
        guard let newValue = newValue, let inputedValue = Double(newValue) else {
                return
            }
        var resultValues: [Double] = currencyValues

        guard index >= 0 && index < resultValues.count else {
                return
            }
            for i in 0..<resultValues.count {
                if i == index {
                    resultValues[i] = inputedValue
                } else {
                    resultValues[i] = inputedValue / currencyValues[index] * currencyValues[i]
                }
            }
        
        convertedResult = resultValues
        convertedResult = convertedResult.map { value in
                return Double(String(format: "%.2f", value)) ?? 0.0
            }
        
        view?.updateTableInfo(with: convertedResult)
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
    
     func createTitleNameForButton(text: String, textSize: CGFloat) -> NSAttributedString {
        let plusImage = UIImage(systemName: Constants.iconPlus) ?? UIImage()
        
        let attributedString = NSMutableAttributedString()
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: R.font.latoRegular(size: textSize)!,
            .foregroundColor: UIColor.hex007AFF
        ]
        
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = plusImage.withRenderingMode(.alwaysTemplate)
        
        let imageString = NSAttributedString(attachment: imageAttachment)
        let textString = NSAttributedString(string: text, attributes: textAttributes)
        
        attributedString.append(imageString)
        attributedString.append(NSAttributedString(string: String("  ")))
        attributedString.append(textString)
        
        return attributedString
    }
    
    func getCurrencyData() {
        let session = URLSession.shared
        let url = URL(string: "https://v6.exchangerate-api.com/v6/82627c0b81b426a2b8186f4d/latest/USD")!
        let task = session.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            do {
                self.currencyData = try JSONDecoder().decode(CurrencyData.self, from: data!)
                
                self.currenciesListData = Array(self.currencyData.conversion_rates.keys)
                
                
                for currency in self.currencies {
                    if let exchangeRate = self.currencyData.conversion_rates[currency] {
                        self.currencyValues.append(exchangeRate)
                    }
                }
                
                DispatchQueue.main.async {
                    self.view?.updateUI(with: self.currencyData)
                }
                
            } catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
}

extension MainPresenter {
    private enum Constants {
        static let iconPlus: String = "plus.circle.fill"
    }
}
