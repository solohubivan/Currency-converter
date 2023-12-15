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
    @IBOutlet weak var describeTimeInterval: UILabel!

    private let datePicker = UIDatePicker()

    private var presenter: ExchangeRatesPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.hexF5F5F5

        presenter = ExchangeRatesPresenter(view: self)

        setupUI()
    }

    // MARK: - SetupUI

    private func setupUI() {
        setupTitleLabel()
        setupDismissButton()
        setupDescriptionLabel()
        setupSearchingDateTF()
        setupDescribeTimeIntervalLabel()
        setupExchangeRateTable()

        createDatepicker()
    }

    private func setupTitleLabel() {
        titleLabel.text = R.string.localizable.exchange_rate()
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
        descriptionLabel.text = R.string.localizable.entere_the_date_to_view_currency_exchange_rates()
        descriptionLabel.font = R.font.latoSemiBold(size: 17)
        descriptionLabel.textColor = UIColor.hex575757
    }

    private func setupSearchingDateTF() {
        searchingDateTF.delegate = self
        searchingDateTF.placeholder = R.string.localizable.dd_mm_yyyy()
        searchingDateTF.textColor = UIColor.systemBlue
        searchingDateTF.font = R.font.latoRegular(size: 18)

        searchingDateTF.overrideUserInterfaceStyle = .light
    }

    private func setupDescribeTimeIntervalLabel() {
        describeTimeInterval.text = R.string.localizable.currency_exchange_rates_are_available_from_december_1_2014()
        describeTimeInterval.font = R.font.latoBold(size: 20)
        describeTimeInterval.textColor = UIColor.lightGray
        describeTimeInterval.textAlignment = .center
    }

    private func setupExchangeRateTable() {
        exchangeRateInfoTable.dataSource = self
        exchangeRateInfoTable.delegate = self
        exchangeRateInfoTable.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellIdentifier)
        exchangeRateInfoTable.isHidden = true

        exchangeRateInfoTable.overrideUserInterfaceStyle = .light

    }

    @IBAction func dismissSelf(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Private Methods

    private func showCurrencyInfoAlert(currencyCode: String, saleRateNB: Double, purchaseRateNB: Double) {

        let message = String(
            format: R.string.localizable.info_alert_message(
                saleRateNB,
                R.string.localizable.uah(),
                purchaseRateNB,
                R.string.localizable.uah()
            ),
            saleRateNB, currencyCode, purchaseRateNB, currencyCode
        )

        let alertController = UIAlertController(
            title: R.string.localizable.exchange_rate(),
            message: message,
            preferredStyle: .alert
        )

        let messageFont = [NSAttributedString.Key.font:
                            R.font.latoSemiBold(size: 15)]
        let messageAttrString = NSMutableAttributedString(string:
        alertController.message ?? "")
        messageAttrString.addAttributes(messageFont as [NSAttributedString.Key: Any], range: NSRange(location: .zero,
        length: messageAttrString.length))
        alertController.setValue(messageAttrString, forKey: Constants.keyAttributedMessage)

        let okAction = UIAlertAction(title: R.string.localizable.ok(), style: .default, handler: nil)
        alertController.addAction(okAction)

        present(alertController, animated: true, completion: nil)
    }

    private func createToolBar() -> UIToolbar {

        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: true)

        return toolbar
    }

    private func createDatepicker() {
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.dateFormat
        if let minDate = dateFormatter.date(from: Constants.minDateToSearch) {
            datePicker.minimumDate = minDate
        }
        if let maxDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) {
            datePicker.maximumDate = maxDate
        }

        searchingDateTF.inputView = datePicker
        searchingDateTF.inputAccessoryView = createToolBar()
    }

    @objc func donePressed() {
        describeTimeInterval.isHidden = true
        exchangeRateInfoTable.isHidden = false

        let dateFormTF = DateFormatter()
        dateFormTF.dateStyle = .medium
        dateFormTF.timeStyle = .none
        self.searchingDateTF.text = dateFormTF.string(from: datePicker.date)

        let dateFormForLink = DateFormatter()
        dateFormForLink.dateFormat = Constants.dateFormat
        presenter.getData(date: dateFormForLink.string(from: datePicker.date))

        self.view.endEditing(true)
    }
}

// MARK: - Extensions

extension ExchangeRatesViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.layer.borderWidth = Constants.borderWidthTF
        textField.layer.borderColor = UIColor.systemBlue.cgColor
        textField.layer.cornerRadius = Constants.cornerRadiusTF
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
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath)
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

extension ExchangeRatesViewController {
    private enum Constants {
        static let cellIdentifier: String = "ExchangeRateCellIdentifier"
 //       static let ukrainianCurrency: String = "UAH"
        static let keyAttributedMessage: String = "attributedMessage"

        static let minDateToSearch: String = "01.12.2014"
        static let dateFormat: String = "dd.MM.yyyy"

        static let borderWidthTF: CGFloat = 1
        static let cornerRadiusTF: CGFloat = 5
    }
}
