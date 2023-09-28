//
//  CurrencyValueTableViewCell.swift
//  Currency converter
//
//  Created by Ivan Solohub on 26.09.2023.
//

import UIKit

class CurrencyValueTableViewCell: UITableViewCell {
    

    @IBOutlet weak var currencyNameLabel: UILabel!
    @IBOutlet weak var currencyValueTF: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCurrencyName()
        setupCurrencyTextField()
    }
    //MARK: - SetupUI
    
    private func setupCurrencyName() {
        currencyNameLabel.attributedText = createTitleNameForLabel(text: "USD")
    }
    
    private func setupCurrencyTextField() {
        currencyValueTF.delegate = self
        currencyValueTF.borderStyle = .none
        currencyValueTF.clearButtonMode = .whileEditing
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: Int(currencyValueTF.frame.height)))
        currencyValueTF.leftView = paddingView
        currencyValueTF.leftViewMode = .always
        currencyValueTF.layer.cornerRadius = 6
        currencyValueTF.layer.backgroundColor = UIColor(red: 0.98, green: 0.969, blue: 0.992, alpha: 1).cgColor
        currencyValueTF.font = R.font.latoSemiBold(size: 14)
        currencyValueTF.textColor = UIColor(red: 0, green: 0.191, blue: 0.4, alpha: 1)
    }
    
    //MARK: - Private Methods
    
    private func createTitleNameForLabel(text: String) -> NSAttributedString {
        let chevronImage = R.image.chevronRight()
        
        let attributedString = NSMutableAttributedString()
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: R.font.latoRegular(size: 14)!,
            .foregroundColor: UIColor(red: 0, green: 0.191, blue: 0.4, alpha: 1)
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
    
}

extension CurrencyValueTableViewCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText: NSString = textField.text! as NSString
        let newText = currentText.replacingCharacters(in: range, with: string)
        
        if newText == "." {
            textField.text = "0."
            return false
        }
        
        let allowedCharacterSet = CharacterSet(charactersIn: "0123456789.")
            if newText.rangeOfCharacter(from: allowedCharacterSet.inverted) != nil {
                return false
            }
        
        let pointCount = newText.components(separatedBy: ".").count - 1
            if pointCount > 1 {
                return false
            }
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(red: 0, green: 0.48, blue: 1, alpha: 1).cgColor
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        textField.layer.borderWidth = .zero
    }
}
