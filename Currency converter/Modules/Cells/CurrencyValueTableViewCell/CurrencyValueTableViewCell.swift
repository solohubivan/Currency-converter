//
//  CurrencyValueTableViewCell.swift
//  Currency converter
//
//  Created by Ivan Solohub on 26.09.2023.
//

import UIKit


class CurrencyValueTableViewCell: UITableViewCell {

    @IBOutlet weak private var currencyNameLabel: UILabel!
    @IBOutlet weak private var currencyValueTF: UITextField!
    
    private var textFieldValueChanged: ((String?) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCurrencyTextField()
    }
    
    func configure(with dataModel: CurrencyDataModel) {
        currencyNameLabel.attributedText = createTitleNameForCurrencyLabel(text: dataModel.name)
        if let calculatedResult = dataModel.calculatedResult {
                currencyValueTF.text = String(format: "%.2f", calculatedResult)
            } else {
                currencyValueTF.text = ""
            }
    }
  
    func updateCurrencyValue(with dataModel: CurrencyDataModel, textFieldValueChange: @escaping (String?) -> Void) {

            self.textFieldValueChanged = textFieldValueChange
        }
    
    //MARK: - Private Methods
    
    private func createTitleNameForCurrencyLabel(text: String) -> NSAttributedString {
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
    
}

extension CurrencyValueTableViewCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText: NSString = (textField.text ?? "") as NSString
        let newText = currentText.replacingCharacters(in: range, with: string)

        let pointCount = newText.components(separatedBy: ".").count - Constants.one
        let allowedCharacterSet = CharacterSet(charactersIn: Constants.allowedCharacters)

        guard pointCount <= Constants.one,
              newText.rangeOfCharacter(from: allowedCharacterSet.inverted) == nil,
              newText != "." else {
            if newText == "." {
                textField.text = "0."
            }
            return false
        }
        return newText.count <= Constants.maxCount
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
/*
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        return true
    }
 */
}

extension CurrencyValueTableViewCell {
    private enum Constants {
        static let allowedCharacters: String = "0123456789."
        
        static let borderWidth: CGFloat = 1
        static let cornerRadiusTF: CGFloat = 6
        
        static let one: Int = 1
        static let maxCount: Int = 12
        static let textLeftPadding: Int = 16
        
    }
}
