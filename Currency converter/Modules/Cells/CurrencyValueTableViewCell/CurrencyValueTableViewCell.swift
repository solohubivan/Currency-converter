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

    private var textFieldValueChanged: CallbackString?

    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
    }

    func configure(with viewModel: CurrencyViewModel, textFieldValueChange: @escaping CallbackString) {

        currencyNameLabel.text = "\(viewModel.name)"
        if let calculatedResult = viewModel.calculatedResult {
            currencyValueTF.text = String(format: "%.2f", calculatedResult).formattedWithSeparator()
        } else {
            currencyValueTF.text = ""
        }

        self.textFieldValueChanged = textFieldValueChange
    }

    // MARK: - Private Methods

    private func setupUI() {
        setupCurrencyNameLabel()
        setupCurrencyTextField()
    }

    private func setupCurrencyNameLabel() {
        currencyNameLabel.font = R.font.latoRegular(size: 14)
        currencyNameLabel.textColor = UIColor.hex003166
    }

    private func setupCurrencyTextField() {
        currencyValueTF.delegate = self
        let paddingView = UIView(frame: CGRect(x: .zero, y: .zero, width: Constants.textLeftPadding, height: Int(currencyValueTF.frame.height)))
        currencyValueTF.leftView = paddingView
        currencyValueTF.leftViewMode = .always
        currencyValueTF.layer.cornerRadius = Constants.cornerRadiusTF
        currencyValueTF.layer.backgroundColor = UIColor.hexFAF7FD.cgColor
        currencyValueTF.font = R.font.latoSemiBold(size: 14)
        currencyValueTF.textColor = UIColor.hex003166
        currencyValueTF.overrideUserInterfaceStyle = .light
    }

    private func activateTextField(_ isActive: Bool) {
        currencyValueTF.layer.borderWidth = isActive ? Constants.borderWidth : .zero
        currencyValueTF.layer.borderColor = isActive ? UIColor.hex007AFF.cgColor : nil
    }
}

extension CurrencyValueTableViewCell: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let currentText: NSString = textField.text! as NSString
        let newText = currentText.replacingCharacters(in: range, with: string.replacingCommaWithDot())

        if !newText.removingSpaces().isValidForTextField() {
            return false
        }

        if newText == "." {
            textField.text = "0."
            return false
        }

        textField.text = newText.formattedWithSeparator()

        return false
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        activateTextField(true)
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        activateTextField(false)
        textFieldValueChanged?(textField.text?.removingSpaces())
    }
}

extension CurrencyValueTableViewCell {
    private enum Constants {
        static let borderWidth: CGFloat = 1
        static let cornerRadiusTF: CGFloat = 6

        static let textLeftPadding: Int = 16

        static let inputMaxCount: Int = 12
        static let oneDot: Int = 1
    }
}
