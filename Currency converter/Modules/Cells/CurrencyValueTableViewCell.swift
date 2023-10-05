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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCurrencyTextField()
    }
    //MARK: - SetupUI
    func configureCell(with viewModel: CurrencyCellViewModel) {
        currencyNameLabel.attributedText = viewModel.currencyName
        currencyValueTF.text = "\(viewModel.currencyValue)"
    }
    
    private func setupCurrencyTextField() {
        currencyValueTF.delegate = self
        currencyValueTF.borderStyle = .none
        currencyValueTF.clearButtonMode = .whileEditing
        let paddingView = UIView(frame: CGRect(x: .zero, y: .zero, width: 16, height: Int(currencyValueTF.frame.height)))
        currencyValueTF.leftView = paddingView
        currencyValueTF.leftViewMode = .always
        currencyValueTF.layer.cornerRadius = 6
        currencyValueTF.layer.backgroundColor = UIColor.hexFAF7FD.cgColor
        currencyValueTF.font = R.font.latoSemiBold(size: 14)
        currencyValueTF.textColor = UIColor.hex003166
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
        textField.layer.borderColor = UIColor.hex007AFF.cgColor
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        textField.layer.borderWidth = .zero
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.currencyValueTF.endEditing(true)
    }
}
