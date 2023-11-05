//
//  ExchangeRatesViewController.swift
//  Currency converter
//
//  Created by Ivan Solohub on 03.11.2023.
//

import UIKit

protocol ExchangeRatesVCProtocol: AnyObject {
    func reloadTable()
}

class ExchangeRatesViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selfDismissButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var searchingDateTF: UITextField!
    @IBOutlet weak var exchangeRateInfoTable: UITableView!

    
    private var presenter: ExchangeRatesPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.hexF5F5F5
        
        presenter = ExchangeRatesPresenter(view: self)
        
        setupUI()
        
   //     presenter.getData(date: "27.06.2020")
    }
    
    //MARK: - SetupUI
    
    private func setupUI() {
        setupTitleLabel()
        setupDismissButton()
        setupDescriptionLabel()
        setupSearchingDateTF()
        setupExchangeRateTable()
    }
    
    private func setupTitleLabel() {
        titleLabel.text = "Exchange Rate"
        titleLabel.font = R.font.sfProTextSemibold(size: 17)
        titleLabel.textColor = UIColor.black
    }
    
    private func setupDismissButton() {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: R.font.sfProTextRegular(size: 17)!,
            .foregroundColor: UIColor.systemBlue
        ]
        
        selfDismissButton.setAttributedTitle(NSAttributedString(string: R.string.localizable.converter(), attributes: attributes), for: .normal)
    }
    
    private func setupDescriptionLabel() {
        descriptionLabel.text = "Enter the date to view currency exchange rates"
        descriptionLabel.font = R.font.latoSemiBold(size: 17)
        descriptionLabel.textColor = UIColor.hex575757
    }
    
    private func setupSearchingDateTF() {
        searchingDateTF.delegate = self
        searchingDateTF.placeholder = "dd.mm.yyyy"
        searchingDateTF.textColor = UIColor.systemBlue
        searchingDateTF.font = R.font.latoRegular(size: 18)
    }
    
    private func setupExchangeRateTable() {
        exchangeRateInfoTable.dataSource = self
        exchangeRateInfoTable.delegate = self
        exchangeRateInfoTable.register(UITableViewCell.self, forCellReuseIdentifier: "ExchangeRateCellIdentifier")
    }
    
    @IBAction func dismissSelf(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func showCurrencyInfoAlert(currencyCode: String, saleRateNB: Double, purchaseRateNB: Double) {
        
        let alertController = UIAlertController(title: currencyCode, message: "National Bank\nSalling Rate is \(saleRateNB) UAH\nBuying Rate is \(purchaseRateNB) UAH", preferredStyle: .alert)
        
        let messageFont = [NSAttributedString.Key.font:
                            R.font.latoSemiBold(size: 15)]
        let messageAttrString = NSMutableAttributedString(string:
        alertController.message ?? "")
        messageAttrString.addAttributes(messageFont as [NSAttributedString.Key : Any], range: NSRange(location: 0,
        length: messageAttrString.length))
        alertController.setValue(messageAttrString, forKey: "attributedMessage")

        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}

//MARK: - Extensions

extension ExchangeRatesViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText: NSString = textField.text! as NSString
        let newText = currentText.replacingCharacters(in: range, with: string)
        
        if textField == searchingDateTF {
            textField.text = newText.formattedText(mask: searchingDateTF.placeholder ?? "")
            return false
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemBlue.cgColor
        textField.layer.cornerRadius = 5
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = .zero
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension ExchangeRatesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getCurrencies().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExchangeRateCellIdentifier", for: indexPath)
        let disclosureIndicator = UITableViewCell.AccessoryType.disclosureIndicator
        
        guard presenter.getCurrencies().indices.contains(indexPath.row) else { return UITableViewCell() }
        let currencyCode = presenter.getCurrencies()[indexPath.row]
        
        if let currencyName = presenter.configureCellName(forCode: currencyCode) {
            cell.textLabel?.text = currencyName
        } else {
            cell.textLabel?.text = currencyCode
        }
        
        cell.textLabel?.font = R.font.latoSemiBold(size: 17)
        cell.accessoryType = disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard presenter.getCurrencies().indices.contains(indexPath.row) else { return }
        let currencyCode = presenter.getCurrencies()[indexPath.row]
        
        if let index = presenter.getCurrencies().firstIndex(of: currencyCode) {
            showCurrencyInfoAlert(currencyCode: currencyCode, saleRateNB: presenter.getSaleRateNB()[index], purchaseRateNB: presenter.getPurchaseRateNB()[index])
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ExchangeRatesViewController: ExchangeRatesVCProtocol {
    
    func reloadTable() {
        exchangeRateInfoTable.reloadData()
    }
}
