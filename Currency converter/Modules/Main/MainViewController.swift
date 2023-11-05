//
//  MainViewController.swift
//  Currency converter
//
//  Created by Ivan Solohub on 15.09.2023.
//

import UIKit
import Reachability


fileprivate enum ConvertingMode {
    case sell
    case buy
}


protocol MainViewProtocol: AnyObject {
    func updateUI(with currencyData: CurrencyData)
    func reloadDataCurrencyInfoTable()
    func updateTableHeight()
}


class MainViewController: UIViewController {
    
    @IBOutlet weak private var mainTitleLabel: UILabel!
    @IBOutlet weak private var currencyShowView: UIView!
    @IBOutlet weak private var sellBuyModeSegmntContrl: UISegmentedControl!
    @IBOutlet weak private var currencyInfoTableView: UITableView!
    @IBOutlet weak private var addCurrencyButton: UIButton!
    @IBOutlet weak private var updatedInfoLabel: UILabel!
    @IBOutlet weak var exchangeRateButton: UIButton!
    
    @IBOutlet weak var currencyInfoTableHeight: NSLayoutConstraint!
    
    private var presenter: MainVCPresenterProtocol!

    private var convertingMode = ConvertingMode.sell
    
    private let refreshControl: UIRefreshControl = {
       let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshActivated), for: .valueChanged)
        return refreshControl
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MainPresenter(view: self)
        
        checkInternetConnectionAndGetData()
        
        setupUI()
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
        convertingMode = sender.selectedSegmentIndex == .zero ? .sell : .buy
        updatePriceValuesWithMode()
    }
    
    private func setupCurrencyInfoTableView() {
        currencyInfoTableView.dataSource = self
        currencyInfoTableView.delegate = self
        currencyInfoTableView.separatorColor = .clear
        currencyInfoTableView.register(UINib(nibName: Constants.currencyInfoTableNibName, bundle: nil), forCellReuseIdentifier: Constants.currencyValuesCellIdentifier)
        
        currencyInfoTableView.refreshControl = refreshControl
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
    
    //MARK: - Private Methods
    
    private func checkInternetConnectionAndGetData() {
        let reachability = try! Reachability()
        if reachability.connection == .wifi || reachability.connection == .cellular {
            
            presenter.getCurrenciesDataValues()
        } else {
            showNoInternetAlert()
        }
    }
    
    private func showNoInternetAlert() {
        let alertController = UIAlertController(
            title: R.string.localizable.no_internet_connection(),
            message: R.string.localizable.please_allow_this_app_to_internet_access(),
            preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: R.string.localizable.use_offline(), style: .cancel, handler: nil)
        let settingsAction = UIAlertAction(title: R.string.localizable.settings(), style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
        
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)

        present(alertController, animated: true, completion: nil)
    }
    
    private func updatePriceValuesWithMode() {
        
        let rowCount = currencyInfoTableView.numberOfRows(inSection: .zero)
        
        switch convertingMode {
        case .sell:
            presenter.updatePriceValues(isSellMode: true)
        case .buy:
            presenter.updatePriceValues(isSellMode: false)
        }
        for row in .zero..<rowCount {
            if let currencyCell = currencyInfoTableView.cellForRow(at: IndexPath(row: row, section: .zero)) as? CurrencyValueTableViewCell {
                presenter.updateCalculatedCurencyValue(with: currencyCell.currencyValueTF.text, at: currencyCell.cellIndex)
            }
        }
    }
    
    @objc private func refreshActivated() {
        let mainVC = MainViewController()
        mainVC.modalPresentationStyle = .fullScreen
        present(mainVC, animated: false)
        refreshControl.endRefreshing()
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
        let textToShare = presenter.createShareText(currencyNames: presenter.getActiveCurrenciesForTable(), currencyValues: presenter.getConvertedResults())
        
        let shareViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        
        present(shareViewController, animated: true, completion: nil)
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return presenter.getActiveCurrenciesForTable().count
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.currencyValuesCellIdentifier, for: indexPath) as! CurrencyValueTableViewCell
        
        let currencyName = presenter.getActiveCurrenciesForTable()[indexPath.row]
        cell.currencyNameLabel.attributedText = presenter.createTitleNameForCurrencyLabel(text: currencyName)
        
        if indexPath.row < presenter.getConvertedResults().count {
            let convertedValue = presenter.getConvertedResults()[indexPath.row]
                cell.currencyValueTF.text = String(convertedValue)
            } else {
                cell.currencyValueTF.text = ""
            }
        
        cell.cellIndex = indexPath.row
        
        cell.textFieldValueChanged = { [weak self] newValue in
            guard let self = self else { return }
            self.presenter.updateCalculatedCurencyValue(with: newValue, at: cell.cellIndex)
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
    
    func updateTableHeight() {
        let rowCount = presenter.getActiveCurrenciesForTable().count
        
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
    }
}
