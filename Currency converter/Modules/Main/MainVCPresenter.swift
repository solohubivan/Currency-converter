//
//  MainVCPresenter.swift
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
}


class MainVCPresenter: MainVCPresenterProtocol {
    
    private var currencyData = CurrencyData()
    private weak var view: MainViewProtocol?
    
    init(view: MainViewProtocol) {
        self.view = view
    }
    
    func configureLastUpdatedLabel() -> String {
        let dateInfo = (currencyData.time_last_update_utc)
        var result = ""
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "E, d MMM yyy HH:mm:ss Z"
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd MMM yyyy h:mm a"
        
        if let date = inputFormatter.date(from: dateInfo) {
            result = "Last Updated \n" + outputFormatter.string(from: date)
        }
        return result
    }
    
     func createTitleNameForButton(text: String, textSize: CGFloat) -> NSAttributedString {
        let plusImage = UIImage(systemName: "plus.circle.fill") ?? UIImage()
        
        let attributedString = NSMutableAttributedString()
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: R.font.latoRegular(size: textSize)!,
            .foregroundColor: UIColor.i007AFF
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
        //        print(self.currencyData)
                
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
