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
    
    private var presenter: MainVCPresenterProtocol!

    private var convertingMode = ConvertingMode.sell
    
    private var isIpad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MainPresenter(view: self)
        
//        checkInternetConnectionAndGetData()
        presenter.getCurrencyData()
        
        setupUI()
    }
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if initialTableViewWidth == nil {
            initialTableViewWidth = currencyShowView.frame.width
        }
    }
    
    override func viewWillLayoutSubviews() {
            super.viewWillLayoutSubviews()
        
        if UIDevice.current.orientation.isLandscape {
            if isIpad {
                currencyInfoTableWidth.constant = Constants.tableSizeForIpad
                indentUnderTitleLabel.constant = Constants.shortIndent
            } else {
                currencyInfoTableWidth.constant = initialTableViewWidth!
                indentUnderTitleLabel.constant = Constants.shortIndent
            }
            
        } else {
            if isIpad {
                currencyInfoTableWidth.constant = Constants.tableSizeForIpad
                indentUnderTitleLabel.constant = Constants.standartIndent
            } else {
                if initialTableViewWidth == nil {
                    currencyInfoTableWidth.constant = currencyShowView.frame.width
                }
                indentUnderTitleLabel.constant = Constants.standartIndent
            }
        }
    }
    
    //MARK: - Setup UI
    
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
        
        currencyShowView.applyShadow(opacity: Constants.viewShadowOpacity, offset: CGSize(width: .zero, height: Constants.viewShadowHeight), radius: Constants.viewShadowRadius, cornerRadius: Constants.viewCornerRadius)
    }
    
    private func setupSwitchModeSegmentedControl() {
        sellBuyModeSegmntContrl.setTitle(R.string.localizable.sell(), forSegmentAt: .zero)
        sellBuyModeSegmntContrl.setTitle(R.string.localizable.buy(), forSegmentAt: Constants.firstSegment)
        sellBuyModeSegmntContrl.backgroundColor = .white
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
        currencyInfoTableView.register(UINib(nibName: Constants.currencyInfoTableNibName, bundle: nil), forCellReuseIdentifier: Constants.currencyValuesCellIdentifier)
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        exchangeRateButton.titleLabel?.font = R.font.latoBold(size: 18)
        exchangeRateButton.titleLabel?.textColor = UIColor.hex007AFF
    }
    
    // MARK: Methods which prevents objects from being overlaid by the keyboard
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        var shouldMoveViewUp = false
        let paddingForKeyboard: CGFloat = 230

        if let activeTextField = self.view.findActiveTextField() {
            let bottomOfTextField = activeTextField.convert(activeTextField.bounds, to: self.view).maxY;
            let topOfKeyboard = self.view.frame.height - keyboardSize.height


            if bottomOfTextField > topOfKeyboard {
                shouldMoveViewUp = true
            }
        }

        if(shouldMoveViewUp) {
            self.view.frame.origin.y = paddingForKeyboard - keyboardSize.height
        }
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
    
    //MARK: - Private Methods

    private func checkInternetConnectionAndGetData() {
        let monitor = NWPathMonitor()
            monitor.pathUpdateHandler = { [weak self] path in
                
                DispatchQueue.main.async {
                    if path.status == .satisfied {
                        self?.presenter.getCurrencyData()
                    } else {
                        self?.showNoInternetAlert()
                    }
                }
            }
        
        let queue = DispatchQueue(label: Constants.queueLabel)
            monitor.start(queue: queue)
    }
    
    private func showNoInternetAlert() {
        let alertController = UIAlertController(
            title: R.string.localizable.no_internet_connection(),
            message: R.string.localizable.please_allow_this_app_to_internet_access(),
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: R.string.localizable.use_offline(), style: .cancel) { [weak self]  _ in
            
  //          self?.presenter.getCurrenciesDataValues(offlineMode: true)
            self?.exchangeRateButton.isHidden = true
        }
        
        let settingsAction = UIAlertAction(title: R.string.localizable.settings(), style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
        
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)

        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - IBActions
    
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

//MARK: - Extentions

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return presenter.getActiveCurrencies().count
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.currencyValuesCellIdentifier, for: indexPath) as! CurrencyValueTableViewCell
        
        let currencyModel = presenter.getActiveCurrencies()[indexPath.row]
        cell.configureCell(with: currencyModel)
        
        cell.updateCurrencyValue(with: currencyModel) { [weak self] newValue in
            guard let self = self, let newValue = newValue, let newDoubleValue = Double(newValue) else { return }
            self.presenter.updateCurrencyValues(inputValue: newDoubleValue, atIndex: indexPath.row)
        }
        return cell
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
        static let currencyValuesCellIdentifier: String = "CurrencyValuesTableViewCell"
        static let currencyInfoTableNibName: String = "CurrencyValueTableViewCell"
        static let queueLabel: String = "Monitor"
        
        static let viewCornerRadius: CGFloat = 10
        static let rateButtonCornerRadius: CGFloat = 14
        static let rateButtonBorderWidth: CGFloat = 1
        
        static let firstSegment: Int = 1
        
        static let viewShadowOpacity: Float = 0.2
        static let viewShadowHeight: CGFloat = 5
        static let viewShadowRadius: CGFloat = 2
        
        static let threeRows: Int = 3
        static let fourRows: Int = 4
        static let fiveRows: Int = 5
        static let sixRows: Int = 6
        static let tableHeight3Rows: CGFloat = 180
        static let tableHeight4Rows: CGFloat = 225
        static let tableHeight5Rows: CGFloat = 285
        static let tableHeight6Rows: CGFloat = 320
        
        static let tableSizeForIpad: CGFloat = 400
        static let shortIndent: CGFloat = 10
        static let standartIndent: CGFloat = 38
    }
}
