//
//  MainViewController.swift
//  Currency converter
//
//  Created by Ivan Solohub on 15.09.2023.
//

import UIKit
import Network

enum ConvertingMode {
    case sell
    case buy
}

protocol MainViewProtocol: AnyObject {
    func updateUI(with currencyData: CurrencyData)
    func reloadDataCurrencyInfoTable()
    func updateTableHeight()
    func showNoDataAlert()
}

class MainViewController: UIViewController {

    @IBOutlet weak private var mainTitleLabel: UILabel!
    @IBOutlet weak private var currencyShowView: UIView!
    @IBOutlet weak private var sellBuyModeSegmntContrl: UISegmentedControl!
    @IBOutlet weak private var currencyInfoTableView: UITableView!
    @IBOutlet weak private var addCurrencyButton: UIButton!
    @IBOutlet weak private var updatedInfoLabel: UILabel!
    @IBOutlet weak private var exchangeRateButton: UIButton!

    @IBOutlet weak private var currencyInfoTableHeight: NSLayoutConstraint!
    @IBOutlet weak private var currencyInfoTableWidth: NSLayoutConstraint!
    @IBOutlet weak private var indentUnderTitleLabel: NSLayoutConstraint!

    private var initialTableViewWidth: CGFloat?

    private let currencyValueCellNib = CurrencyValueTableViewCell.nib

    private var presenter: MainVCPresenterProtocol!

    private var convertingMode = ConvertingMode.sell

    private var isIpad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = MainPresenter(view: self)

        checkInternetConnectionAndGetData()

        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if initialTableViewWidth == nil && UIDevice.current.orientation.isPortrait {
            initialTableViewWidth = currencyShowView.frame.width
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        updateLayoutBasedOnOrientation()
        configureExchangeRateButtonStyle()
    }

    // MARK: - Setup UI

    private func setupUI() {
        setupMainTitleLabel()
        setupCurrencyShowView()
        setupSwitchModeSegmentedControl()
        setupCurrencyInfoTableView()
        setupAddCurrencyButton()
        setupUpdateInfoLabel()
        setupExchangeRateButton()

        setupViewDismissKeyboardGesture()
    }

    private func setupMainTitleLabel() {
        mainTitleLabel.text = R.string.localizable.currency_converter()
        mainTitleLabel.font = R.font.latoExtraBold(size: 24)
        mainTitleLabel.textColor = .white
    }

    private func setupCurrencyShowView() {
        currencyShowView.layer.cornerRadius = Constants.viewCornerRadius
        currencyShowView.backgroundColor = .white

        currencyShowView.applyShadow(
            opacity: Constants.viewShadowOpacity,
            offset: Constants.shadowOffset,
            radius: Constants.viewShadowRadius,
            cornerRadius: Constants.viewCornerRadius
        )
    }

    private func setupSwitchModeSegmentedControl() {
        sellBuyModeSegmntContrl.setTitle(R.string.localizable.sell(), forSegmentAt: .zero)
        sellBuyModeSegmntContrl.setTitle(R.string.localizable.buy(), forSegmentAt: Constants.one)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            for item in .zero...(self.sellBuyModeSegmntContrl.numberOfSegments-Constants.one) {
                let backgroundSegmentView = self.sellBuyModeSegmntContrl.subviews[item]
                backgroundSegmentView.isHidden = true
            }
        }

        sellBuyModeSegmntContrl.selectedSegmentTintColor = UIColor.hex007AFF

        let normalTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.hex003166,
            .font: R.font.latoRegular(size: 18)!
        ]
        sellBuyModeSegmntContrl.setTitleTextAttributes(normalTextAttributes, for: .normal)

        let selectedTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: R.font.latoRegular(size: 18)!
        ]
        sellBuyModeSegmntContrl.setTitleTextAttributes(selectedTextAttributes, for: .selected)

        sellBuyModeSegmntContrl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
    }

    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        let newMode = sender.selectedSegmentIndex == .zero ? ConvertingMode.sell : ConvertingMode.buy

        presenter.setConvertingMode(newMode)
        presenter.recalculateValuesForAllCurrencies()
    }

    private func setupCurrencyInfoTableView() {
        currencyInfoTableView.dataSource = self
        currencyInfoTableView.delegate = self
        currencyInfoTableView.separatorColor = .clear
        currencyInfoTableView.backgroundColor = .clear
        currencyInfoTableView.register(currencyValueCellNib, forCellReuseIdentifier: Constants.currencyValuesCellId)
        setupRefreshControl()
    }

    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshActivated), for: .valueChanged)
        currencyInfoTableView.refreshControl = refreshControl
    }

    @objc private func refreshActivated() {
        let mainVC = MainViewController()
        mainVC.modalPresentationStyle = .fullScreen
        present(mainVC, animated: false)
    }

    private func setupAddCurrencyButton() {
        addCurrencyButton.setTitle(R.string.localizable.add_currency(), for: .normal)
        addCurrencyButton.titleLabel?.font = R.font.latoRegular(size: 13)
        addCurrencyButton.titleLabel?.textColor = UIColor.hex007AFF
    }

    private func setupUpdateInfoLabel() {
        updatedInfoLabel.font = R.font.latoRegular(size: 12)
        updatedInfoLabel.textColor = UIColor.hex575757
    }

    private func setupExchangeRateButton() {
        exchangeRateButton.setTitle(R.string.localizable.national_bank_exchange_rate(), for: .normal)
        exchangeRateButton.layer.borderWidth = Constants.rateButtonBorderWidth
        exchangeRateButton.layer.cornerRadius = Constants.rateButtonCornerRadius
        exchangeRateButton.layer.borderColor = UIColor.hex007AFF.cgColor
    }

    private func configureExchangeRateButtonStyle() {
        exchangeRateButton.titleLabel?.font = R.font.latoBold(size: 18)
        exchangeRateButton.titleLabel?.textColor = UIColor.hex007AFF
    }

    // MARK: For allow dismiss keyboard by the tap on any free screen place

    private func setupViewDismissKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        self.view.endEditing(true)
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = .zero
    }

    // MARK: - Private Methods

    private func updateLayoutBasedOnOrientation() {
        let isLandscape = UIDevice.current.orientation.isLandscape
        let tableWidth = isIpad ? Constants.tableSizeForIpad : (initialTableViewWidth ?? currencyShowView.frame.width)
        let topIndent = isLandscape ? Constants.landscapeTopIndent : Constants.standartTopIndent

        currencyInfoTableWidth.constant = tableWidth
        indentUnderTitleLabel.constant = topIndent
    }

    private func checkInternetConnectionAndGetData() {

        if NetworkMonitor.shared.isConnected {
            self.presenter.getCurrencyData(offlineMode: false)
        } else {
            self.presenter.getCurrencyData(offlineMode: true)
            DispatchQueue.main.async {
                self.showNoInternetAlert()
                self.exchangeRateButton.isHidden = true
            }
        }
    }

    private func showNoInternetAlert() {
        let alertController = UIAlertController(
            title: R.string.localizable.no_internet_connection(),
            message: R.string.localizable.please_allow_this_app_to_internet_access(),
            preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: R.string.localizable.use_offline(), style: .cancel)

        let settingsAction = UIAlertAction(title: R.string.localizable.settings(), style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }

        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)

        present(alertController, animated: true, completion: nil)
    }

    // MARK: - IBActions

    @IBAction func jumpToExchangeRateVC(_ sender: Any) {
        let exchangeRateVC = ExchangeRatesViewController()
        exchangeRateVC.modalPresentationStyle = .formSheet
        present(exchangeRateVC, animated: true)
    }

    @IBAction func presentCurrencyListVC(_ sender: Any) {
        let currencyListVC = CurrencyListViewController()
        currencyListVC.presenter = self.presenter
        currencyListVC.modalPresentationStyle = .formSheet
        present(currencyListVC, animated: true)
    }

    @IBAction func shareCurrencyInfo(_ sender: Any) {
        let currencyNames = presenter.getActiveCurrencies().map { $0.name }
        let currencyValues = presenter.getActiveCurrencies().compactMap { $0.calculatedResult }

        let textToShare = presenter.createShareText(currencyNames: currencyNames, currencyValues: currencyValues)

        let shareViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        present(shareViewController, animated: true, completion: nil)
    }
}

// MARK: - Extentions

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return presenter.getActiveCurrenciesCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.currencyValuesCellId,
            for: indexPath
        ) as? CurrencyValueTableViewCell ?? CurrencyValueTableViewCell()

        let currencyModel = presenter.getActiveCurrencies()[indexPath.row]

        cell.configure(with: currencyModel, textFieldValueChanged: { [weak self] newValue in
            self?.presenter.updateCurrencyValues(inputValue: newValue ?? "", atIndex: indexPath.row)
        })

        return cell
    }

    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            tableView.beginUpdates()
            presenter.removeActiveCurrencies(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }
}

extension MainViewController: MainViewProtocol {

    func updateUI(with currencyData: CurrencyData) {
        updatedInfoLabel.text = presenter.configureLastUpdatedLabel()
    }

    func reloadDataCurrencyInfoTable() {
        currencyInfoTableView.reloadData()
    }

    func showNoDataAlert() {
        let alertController = UIAlertController(
            title: R.string.localizable.no_data(),
            message: R.string.localizable.please_allow_this_app_to_internet_access(),
            preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: R.string.localizable.settings(), style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
        alertController.addAction(settingsAction)

        present(alertController, animated: true, completion: nil)
    }

    func updateTableHeight() {
        let rowCount = presenter.getActiveCurrencies().count

        if rowCount <= Constants.threeRows {
            currencyInfoTableHeight.constant = Constants.tableHeight3Rows
        }
        if rowCount == Constants.fourRows {
            currencyInfoTableHeight.constant = Constants.tableHeight4Rows
        }
        if rowCount == Constants.fiveRows {
            currencyInfoTableHeight.constant = Constants.tableHeight5Rows
        }
        if rowCount >= Constants.sixRows {
            currencyInfoTableHeight.constant = Constants.tableHeight6Rows
        }
    }
}

extension MainViewController {
    private enum Constants {
        static let currencyValuesCellId: String = "CurrencyValueTableViewCell"

        static let viewCornerRadius: CGFloat = 10
        static let rateButtonCornerRadius: CGFloat = 14
        static let rateButtonBorderWidth: CGFloat = 1

        static let viewShadowOpacity: Float = 0.2
        static let viewShadowHeight: CGFloat = 5
        static let viewShadowRadius: CGFloat = 2
        static let shadowOffset = CGSize(width: .zero, height: viewShadowHeight)

        static let one: Int = 1
        static let threeRows: Int = 3
        static let fourRows: Int = 4
        static let fiveRows: Int = 5
        static let sixRows: Int = 6

        static let tableHeight3Rows: CGFloat = 180
        static let tableHeight4Rows: CGFloat = 225
        static let tableHeight5Rows: CGFloat = 285
        static let tableHeight6Rows: CGFloat = 320
        static let tableSizeForIpad: CGFloat = 400
        static let landscapeTopIndent: CGFloat = 10
        static let standartTopIndent: CGFloat = 38
    }
}
