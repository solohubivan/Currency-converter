//
//  MainViewController.swift
//  Currency converter
//
//  Created by Ivan Solohub on 15.09.2023.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak private var mainTitleLabel: UILabel!
    @IBOutlet weak private var currencyShowView: UIView!
    @IBOutlet weak private var sellBuyModeSegmntContrl: UISegmentedControl!
    @IBOutlet weak private var currencyInfoTableView: UITableView!
    @IBOutlet weak private var addCurrencyButton: UIButton!
    @IBOutlet weak private var updatedInfoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    //MARK: - Setup UI
    
    private func setupUI() {
        setupMainTitleLabel()
        setupCurrencyShowView()
        setupSwitchModeSegmentedControl()
        setupAddCurrencyButton()
        setupUpdateInfoLabel()
    }
    
    private func setupMainTitleLabel() {
        mainTitleLabel.text = "Currency Converter"
        mainTitleLabel.font = R.font.latoExtraBold(size: 24)
        mainTitleLabel.textColor = .white
    }
    
    private func setupCurrencyShowView() {
        currencyShowView.layer.cornerRadius = 10
        currencyShowView.backgroundColor = .white
        
        currencyShowView.applyShadow(opacity: 0.2, offset: CGSize(width: .zero, height: 5), radius: 2, cornerRadius: 10)
    }
    
    private func setupSwitchModeSegmentedControl() {
        sellBuyModeSegmntContrl.setTitle("Sell", forSegmentAt: 0)
        sellBuyModeSegmntContrl.setTitle("Buy", forSegmentAt: 1)
        sellBuyModeSegmntContrl.backgroundColor = .white
        sellBuyModeSegmntContrl.selectedSegmentTintColor = UIColor(red: 0, green: 0.478, blue: 1, alpha: 1)
        
        let normalTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 0, green: 0.191, blue: 0.4, alpha: 1),
            .font: R.font.latoRegular(size: 18)!
        ]
        sellBuyModeSegmntContrl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        
        let selectedTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: R.font.latoRegular(size: 18)!
        ]
        sellBuyModeSegmntContrl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
    }
    
    private func setupCurrencyInfoTableView() {
 //       currencyInfoTableView.dataSource = self
 //       currencyInfoTableView.delegate = self
        currencyInfoTableView.separatorColor = .clear
   //     currencyInfoTableView.register(UINib(nibName: Constants.nibNameCustomCell, bundle: nil), forCellReuseIdentifier: Constants.cellIdentifier)
    }
    
    private func setupAddCurrencyButton() {
        addCurrencyButton.setAttributedTitle(createTitleNameForButton(text: "Add Currency", textSize: 13), for: .normal)
    }
    
    private func setupUpdateInfoLabel() {
        updatedInfoLabel.text = "Last Updated"
        updatedInfoLabel.font = R.font.latoRegular(size: 12)
        updatedInfoLabel.textColor = UIColor(red: 0.342, green: 0.342, blue: 0.342, alpha: 1)
    }
    
    //MARK: - Private Methods
    
    private func createTitleNameForButton(text: String, textSize: CGFloat) -> NSAttributedString {
        let plusImage = UIImage(systemName: "plus.circle.fill") ?? UIImage()
        
        let attributedString = NSMutableAttributedString()
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: R.font.latoRegular(size: textSize)!,
            .foregroundColor: UIColor.i007AFF
        ]
        
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = plusImage.withRenderingMode(.alwaysTemplate)
        
        let imageString = NSAttributedString(attachment: imageAttachment)
        let textString = NSAttributedString(string: text, attributes: textAttributes)
        
        attributedString.append(imageString)
        attributedString.append(NSAttributedString(string: String("  ")))
        attributedString.append(textString)
        
        return attributedString
    }

}
/*
extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
    
}
*/
