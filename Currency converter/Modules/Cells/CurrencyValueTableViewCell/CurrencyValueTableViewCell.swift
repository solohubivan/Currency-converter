//
//  CurrencyValueTableViewCell.swift
//  Currency converter
//
//  Created by Ivan Solohub on 26.09.2023.
//

import UIKit

struct CurrencyCellViewModel {
    let currencyName: NSAttributedString
    let currencyValue: Double
}

class CurrencyValueTableViewCell: UITableViewCell {

    @IBOutlet weak var currencyNameLabel: UILabel!
    @IBOutlet weak var currencyValueTF: UITextField!
    

    var textFieldValueChanged: ((_ inputedValue: String?) -> Void)?
    var cellIndex: Int = .zero
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCurrencyTextField()
    }
    
    func configureCell(with viewModel: CurrencyCellViewModel) {
        currencyNameLabel.attributedText = viewModel.currencyName
        currencyValueTF.text = "\(viewModel.currencyValue)"
    }
    
    private func setupCurrencyTextField() {
        currencyValueTF.delegate = self
        currencyValueTF.borderStyle = .none
        currencyValueTF.clearButtonMode = .whileEditing
        currencyValueTF.keyboardType = .decimalPad
        let paddingView = UIView(frame: CGRect(x: .zero, y: .zero, width: Constants.textLeftPadding, height: Int(currencyValueTF.frame.height)))
        currencyValueTF.leftView = paddingView
        currencyValueTF.leftViewMode = .always
        currencyValueTF.layer.cornerRadius = Constants.cornerRadiusTF
        currencyValueTF.layer.backgroundColor = UIColor.hexFAF7FD.cgColor
        currencyValueTF.font = R.font.latoSemiBold(size: 14)
        currencyValueTF.textColor = UIColor.hex003166
        
        currencyValueTF.overrideUserInterfaceStyle = .light
    }
    
    func formatNumberWithThousandsSeparator(_ number: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = " "
        return numberFormatter.string(from: NSNumber(value: number)) ?? ""
    }
}

extension CurrencyValueTableViewCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText: NSString = (textField.text ?? "") as NSString
        let newText = currentText.replacingCharacters(in: range, with: string)
        
        let pointCount = newText.components(separatedBy: ".").count - Constants.one
            if pointCount > Constants.one {
                return false
        }
        
        let allowedCharacterSet = CharacterSet(charactersIn: "0123456789.")
            if newText.rangeOfCharacter(from: allowedCharacterSet.inverted) != nil {
                return false
            }
        
        if newText == "." {
            textField.text = "0."
            return false
        }

        return newText.count <= 12
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.layer.borderWidth = Constants.borderWidth
        textField.layer.borderColor = UIColor.hex007AFF.cgColor
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        textField.layer.borderWidth = .zero
        textFieldValueChanged?(textField.text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        return true
    }
}

extension CurrencyValueTableViewCell {
    private enum Constants {
        static let borderWidth: CGFloat = 1
        static let cornerRadiusTF: CGFloat = 6
        
        static let one: Int = 1
        
        static let textLeftPadding: Int = 16
    }
}
