//
// This is a generated file, do not edit!
// Generated by R.swift, see https://github.com/mac-cain13/R.swift
//

import Foundation
import RswiftResources
import UIKit

private class BundleFinder {}
let R = _R(bundle: Bundle(for: BundleFinder.self))

struct _R {
  let bundle: Foundation.Bundle

  let reuseIdentifier = reuseIdentifier()

  var string: string { .init(bundle: bundle, preferredLanguages: nil, locale: nil) }
  var color: color { .init(bundle: bundle) }
  var image: image { .init(bundle: bundle) }
  var info: info { .init(bundle: bundle) }
  var font: font { .init(bundle: bundle) }
  var file: file { .init(bundle: bundle) }
  var nib: nib { .init(bundle: bundle) }
  var storyboard: storyboard { .init(bundle: bundle) }

  func string(bundle: Foundation.Bundle) -> string {
    .init(bundle: bundle, preferredLanguages: nil, locale: nil)
  }
  func string(locale: Foundation.Locale) -> string {
    .init(bundle: bundle, preferredLanguages: nil, locale: locale)
  }
  func string(preferredLanguages: [String], locale: Locale? = nil) -> string {
    .init(bundle: bundle, preferredLanguages: preferredLanguages, locale: locale)
  }
  func color(bundle: Foundation.Bundle) -> color {
    .init(bundle: bundle)
  }
  func image(bundle: Foundation.Bundle) -> image {
    .init(bundle: bundle)
  }
  func info(bundle: Foundation.Bundle) -> info {
    .init(bundle: bundle)
  }
  func font(bundle: Foundation.Bundle) -> font {
    .init(bundle: bundle)
  }
  func file(bundle: Foundation.Bundle) -> file {
    .init(bundle: bundle)
  }
  func nib(bundle: Foundation.Bundle) -> nib {
    .init(bundle: bundle)
  }
  func storyboard(bundle: Foundation.Bundle) -> storyboard {
    .init(bundle: bundle)
  }
  func validate() throws {
    try self.font.validate()
    try self.nib.validate()
    try self.storyboard.validate()
  }

  struct project {
    let developmentRegion = "en"
  }

  /// This `_R.string` struct is generated, and contains static references to 1 localization tables.
  struct string {
    let bundle: Foundation.Bundle
    let preferredLanguages: [String]?
    let locale: Locale?
    var localizable: localizable { .init(source: .init(bundle: bundle, tableName: "Localizable", preferredLanguages: preferredLanguages, locale: locale)) }

    func localizable(preferredLanguages: [String]) -> localizable {
      .init(source: .init(bundle: bundle, tableName: "Localizable", preferredLanguages: preferredLanguages, locale: locale))
    }


    /// This `_R.string.localizable` struct is generated, and contains static references to 23 localization keys.
    struct localizable {
      let source: RswiftResources.StringResource.Source

      /// Value: Add Currency
      ///
      /// Key: add_currency
      var add_currency: RswiftResources.StringResource { .init(key: "add_currency", tableName: "Localizable", source: source, developmentValue: nil, comment: nil) }

      /// Value: Added
      ///
      /// Key: added
      var added: RswiftResources.StringResource { .init(key: "added", tableName: "Localizable", source: source, developmentValue: nil, comment: nil) }

      /// Value: Buy
      ///
      /// Key: buy
      var buy: RswiftResources.StringResource { .init(key: "buy", tableName: "Localizable", source: source, developmentValue: nil, comment: nil) }

      /// Value: Buying Rate is
      ///
      /// Key: buying_rate_is
      var buying_rate_is: RswiftResources.StringResource { .init(key: "buying_rate_is", tableName: "Localizable", source: source, developmentValue: nil, comment: nil) }

      /// Value: Converter
      ///
      /// Key: converter
      var converter: RswiftResources.StringResource { .init(key: "converter", tableName: "Localizable", source: source, developmentValue: nil, comment: nil) }

      /// Value: Currency
      ///
      /// Key: currency
      var currency: RswiftResources.StringResource { .init(key: "currency", tableName: "Localizable", source: source, developmentValue: nil, comment: nil) }

      /// Value: Currency Converter
      ///
      /// Key: currency_converter
      var currency_converter: RswiftResources.StringResource { .init(key: "currency_converter", tableName: "Localizable", source: source, developmentValue: nil, comment: nil) }

      /// Value: Currency exchange rates are available from December 1, 2014
      ///
      /// Key: currency_exchange_rates_are_available_from_december_1_2014
      var currency_exchange_rates_are_available_from_december_1_2014: RswiftResources.StringResource { .init(key: "currency_exchange_rates_are_available_from_december_1_2014", tableName: "Localizable", source: source, developmentValue: nil, comment: nil) }

      /// Value: dd.mm.yyyy
      ///
      /// Key: dd_mm_yyyy
      var dd_mm_yyyy: RswiftResources.StringResource { .init(key: "dd_mm_yyyy", tableName: "Localizable", source: source, developmentValue: nil, comment: nil) }

      /// Value: Enter the date to view currency exchange rates
      ///
      /// Key: entere_the_date_to_view_currency_exchange_rates
      var entere_the_date_to_view_currency_exchange_rates: RswiftResources.StringResource { .init(key: "entere_the_date_to_view_currency_exchange_rates", tableName: "Localizable", source: source, developmentValue: nil, comment: nil) }

      /// Value: Exchange Rate
      ///
      /// Key: exchange_rate
      var exchange_rate: RswiftResources.StringResource { .init(key: "exchange_rate", tableName: "Localizable", source: source, developmentValue: nil, comment: nil) }

      /// Value: Last Updated
      ///
      /// Key: last_updated
      var last_updated: RswiftResources.StringResource { .init(key: "last_updated", tableName: "Localizable", source: source, developmentValue: nil, comment: nil) }

      /// Value: National Bank
      ///
      /// Key: national_bank
      var national_bank: RswiftResources.StringResource { .init(key: "national_bank", tableName: "Localizable", source: source, developmentValue: nil, comment: nil) }

      /// Value: National Bank Exchange Rate
      ///
      /// Key: national_bank_exchange_rate
      var national_bank_exchange_rate: RswiftResources.StringResource { .init(key: "national_bank_exchange_rate", tableName: "Localizable", source: source, developmentValue: nil, comment: nil) }

      /// Value: No data
      ///
      /// Key: no_data
      var no_data: RswiftResources.StringResource { .init(key: "no_data", tableName: "Localizable", source: source, developmentValue: nil, comment: nil) }

      /// Value: No internet connection
      ///
      /// Key: no_internet_connection
      var no_internet_connection: RswiftResources.StringResource { .init(key: "no_internet_connection", tableName: "Localizable", source: source, developmentValue: nil, comment: nil) }

      /// Value: OK
      ///
      /// Key: ok
      var ok: RswiftResources.StringResource { .init(key: "ok", tableName: "Localizable", source: source, developmentValue: nil, comment: nil) }

      /// Value: Please allow this app to internet access
      ///
      /// Key: please_allow_this_app_to_internet_access
      var please_allow_this_app_to_internet_access: RswiftResources.StringResource { .init(key: "please_allow_this_app_to_internet_access", tableName: "Localizable", source: source, developmentValue: nil, comment: nil) }

      /// Value: Popular
      ///
      /// Key: popular
      var popular: RswiftResources.StringResource { .init(key: "popular", tableName: "Localizable", source: source, developmentValue: nil, comment: nil) }

      /// Value: Salling Rate is
      ///
      /// Key: salling_rate_is
      var salling_rate_is: RswiftResources.StringResource { .init(key: "salling_rate_is", tableName: "Localizable", source: source, developmentValue: nil, comment: nil) }

      /// Value: Sell
      ///
      /// Key: sell
      var sell: RswiftResources.StringResource { .init(key: "sell", tableName: "Localizable", source: source, developmentValue: nil, comment: nil) }

      /// Value: Settings
      ///
      /// Key: settings
      var settings: RswiftResources.StringResource { .init(key: "settings", tableName: "Localizable", source: source, developmentValue: nil, comment: nil) }

      /// Value: Use Offline
      ///
      /// Key: use_offline
      var use_offline: RswiftResources.StringResource { .init(key: "use_offline", tableName: "Localizable", source: source, developmentValue: nil, comment: nil) }
    }
  }

  /// This `_R.color` struct is generated, and contains static references to 1 colors.
  struct color {
    let bundle: Foundation.Bundle

    /// Color `AccentColor`.
    var accentColor: RswiftResources.ColorResource { .init(name: "AccentColor", path: [], bundle: bundle) }
  }

  /// This `_R.image` struct is generated, and contains static references to 3 images.
  struct image {
    let bundle: Foundation.Bundle

    /// Image `chevronRight`.
    var chevronRight: RswiftResources.ImageResource { .init(name: "chevronRight", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `headerBlue`.
    var headerBlue: RswiftResources.ImageResource { .init(name: "headerBlue", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }

    /// Image `shareButtonImmage`.
    var shareButtonImmage: RswiftResources.ImageResource { .init(name: "shareButtonImmage", path: [], bundle: bundle, locale: nil, onDemandResourceTags: nil) }
  }

  /// This `_R.info` struct is generated, and contains static references to 1 properties.
  struct info {
    let bundle: Foundation.Bundle
    var uiApplicationSceneManifest: uiApplicationSceneManifest { .init(bundle: bundle) }

    func uiApplicationSceneManifest(bundle: Foundation.Bundle) -> uiApplicationSceneManifest {
      .init(bundle: bundle)
    }

    struct uiApplicationSceneManifest {
      let bundle: Foundation.Bundle

      let uiApplicationSupportsMultipleScenes: Bool = false

      var _key: String { bundle.infoDictionaryString(path: ["UIApplicationSceneManifest"], key: "_key") ?? "UIApplicationSceneManifest" }
      var uiSceneConfigurations: uiSceneConfigurations { .init(bundle: bundle) }

      func uiSceneConfigurations(bundle: Foundation.Bundle) -> uiSceneConfigurations {
        .init(bundle: bundle)
      }

      struct uiSceneConfigurations {
        let bundle: Foundation.Bundle
        var _key: String { bundle.infoDictionaryString(path: ["UIApplicationSceneManifest", "UISceneConfigurations"], key: "_key") ?? "UISceneConfigurations" }
        var uiWindowSceneSessionRoleApplication: uiWindowSceneSessionRoleApplication { .init(bundle: bundle) }

        func uiWindowSceneSessionRoleApplication(bundle: Foundation.Bundle) -> uiWindowSceneSessionRoleApplication {
          .init(bundle: bundle)
        }

        struct uiWindowSceneSessionRoleApplication {
          let bundle: Foundation.Bundle
          var defaultConfiguration: defaultConfiguration { .init(bundle: bundle) }

          func defaultConfiguration(bundle: Foundation.Bundle) -> defaultConfiguration {
            .init(bundle: bundle)
          }

          struct defaultConfiguration {
            let bundle: Foundation.Bundle
            var uiSceneConfigurationName: String { bundle.infoDictionaryString(path: ["UIApplicationSceneManifest", "UISceneConfigurations", "UIWindowSceneSessionRoleApplication"], key: "UISceneConfigurationName") ?? "Default Configuration" }
            var uiSceneDelegateClassName: String { bundle.infoDictionaryString(path: ["UIApplicationSceneManifest", "UISceneConfigurations", "UIWindowSceneSessionRoleApplication"], key: "UISceneDelegateClassName") ?? "$(PRODUCT_MODULE_NAME).SceneDelegate" }
          }
        }
      }
    }
  }

  /// This `_R.font` struct is generated, and contains static references to 6 fonts.
  struct font: Sequence {
    let bundle: Foundation.Bundle

    /// Font `Lato-Bold`.
    var latoBold: RswiftResources.FontResource { .init(name: "Lato-Bold", bundle: bundle, filename: "Lato-Bold.ttf") }

    /// Font `Lato-ExtraBold`.
    var latoExtraBold: RswiftResources.FontResource { .init(name: "Lato-ExtraBold", bundle: bundle, filename: "Lato-ExtraBold.ttf") }

    /// Font `Lato-Regular`.
    var latoRegular: RswiftResources.FontResource { .init(name: "Lato-Regular", bundle: bundle, filename: "Lato-Regular.ttf") }

    /// Font `Lato-SemiBold`.
    var latoSemiBold: RswiftResources.FontResource { .init(name: "Lato-SemiBold", bundle: bundle, filename: "Lato-SemiBold.ttf") }

    /// Font `SFProText-Regular`.
    var sfProTextRegular: RswiftResources.FontResource { .init(name: "SFProText-Regular", bundle: bundle, filename: "SFProText-Regular.ttf") }

    /// Font `SFProText-Semibold`.
    var sfProTextSemibold: RswiftResources.FontResource { .init(name: "SFProText-Semibold", bundle: bundle, filename: "SFProText-Semibold.ttf") }

    func makeIterator() -> IndexingIterator<[RswiftResources.FontResource]> {
      [latoBold, latoExtraBold, latoRegular, latoSemiBold, sfProTextRegular, sfProTextSemibold].makeIterator()
    }
    func validate() throws {
      for font in self {
        if !font.canBeLoaded() { throw RswiftResources.ValidationError("[R.swift] Font '\(font.name)' could not be loaded, is '\(font.filename)' added to the UIAppFonts array in this targets Info.plist?") }
      }
    }
  }

  /// This `_R.file` struct is generated, and contains static references to 6 resource files.
  struct file {
    let bundle: Foundation.Bundle

    /// Resource file `Lato-Bold.ttf`.
    var latoBoldTtf: RswiftResources.FileResource { .init(name: "Lato-Bold", pathExtension: "ttf", bundle: bundle, locale: LocaleReference.none) }

    /// Resource file `Lato-ExtraBold.ttf`.
    var latoExtraBoldTtf: RswiftResources.FileResource { .init(name: "Lato-ExtraBold", pathExtension: "ttf", bundle: bundle, locale: LocaleReference.none) }

    /// Resource file `Lato-Regular.ttf`.
    var latoRegularTtf: RswiftResources.FileResource { .init(name: "Lato-Regular", pathExtension: "ttf", bundle: bundle, locale: LocaleReference.none) }

    /// Resource file `Lato-SemiBold.ttf`.
    var latoSemiBoldTtf: RswiftResources.FileResource { .init(name: "Lato-SemiBold", pathExtension: "ttf", bundle: bundle, locale: LocaleReference.none) }

    /// Resource file `SFProText-Regular.ttf`.
    var sfProTextRegularTtf: RswiftResources.FileResource { .init(name: "SFProText-Regular", pathExtension: "ttf", bundle: bundle, locale: LocaleReference.none) }

    /// Resource file `SFProText-Semibold.ttf`.
    var sfProTextSemiboldTtf: RswiftResources.FileResource { .init(name: "SFProText-Semibold", pathExtension: "ttf", bundle: bundle, locale: LocaleReference.none) }
  }

  /// This `_R.nib` struct is generated, and contains static references to 4 nibs.
  struct nib {
    let bundle: Foundation.Bundle

    /// Nib `CurrencyListViewController`.
    var currencyListViewController: RswiftResources.NibReference<UIKit.UIView> { .init(name: "CurrencyListViewController", bundle: bundle) }

    /// Nib `CurrencyValueTableViewCell`.
    var currencyValueTableViewCell: RswiftResources.NibReferenceReuseIdentifier<CurrencyValueTableViewCell, CurrencyValueTableViewCell> { .init(name: "CurrencyValueTableViewCell", bundle: bundle, identifier: "CurrencyValuesTableViewCell") }

    /// Nib `ExchangeRatesViewController`.
    var exchangeRatesViewController: RswiftResources.NibReference<UIKit.UIView> { .init(name: "ExchangeRatesViewController", bundle: bundle) }

    /// Nib `MainViewController`.
    var mainViewController: RswiftResources.NibReference<UIKit.UIView> { .init(name: "MainViewController", bundle: bundle) }

    func validate() throws {
      if #available(iOS 13.0, *) { if UIKit.UIImage(systemName: "chevron.backward") == nil { throw RswiftResources.ValidationError("[R.swift] System image named 'chevron.backward' is used in nib 'CurrencyListViewController', but couldn't be loaded.") } }
      if UIKit.UIImage(named: "chevronRight", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'chevronRight' is used in nib 'CurrencyValueTableViewCell', but couldn't be loaded.") }
      if #available(iOS 13.0, *) { if UIKit.UIImage(systemName: "chevron.backward") == nil { throw RswiftResources.ValidationError("[R.swift] System image named 'chevron.backward' is used in nib 'ExchangeRatesViewController', but couldn't be loaded.") } }
      if UIKit.UIImage(named: "headerBlue", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'headerBlue' is used in nib 'MainViewController', but couldn't be loaded.") }
      if #available(iOS 13.0, *) { if UIKit.UIImage(systemName: "plus.circle.fill") == nil { throw RswiftResources.ValidationError("[R.swift] System image named 'plus.circle.fill' is used in nib 'MainViewController', but couldn't be loaded.") } }
      if UIKit.UIImage(named: "shareButtonImmage", in: bundle, compatibleWith: nil) == nil { throw RswiftResources.ValidationError("[R.swift] Image named 'shareButtonImmage' is used in nib 'MainViewController', but couldn't be loaded.") }
    }
  }

  /// This `_R.reuseIdentifier` struct is generated, and contains static references to 1 reuse identifiers.
  struct reuseIdentifier {

    /// Reuse identifier `CurrencyValuesTableViewCell`.
    let currencyValuesTableViewCell: RswiftResources.ReuseIdentifier<CurrencyValueTableViewCell> = .init(identifier: "CurrencyValuesTableViewCell")
  }

  /// This `_R.storyboard` struct is generated, and contains static references to 1 storyboards.
  struct storyboard {
    let bundle: Foundation.Bundle
    var launchScreen: launchScreen { .init(bundle: bundle) }

    func launchScreen(bundle: Foundation.Bundle) -> launchScreen {
      .init(bundle: bundle)
    }
    func validate() throws {
      try self.launchScreen.validate()
    }


    /// Storyboard `LaunchScreen`.
    struct launchScreen: RswiftResources.StoryboardReference, RswiftResources.InitialControllerContainer {
      typealias InitialController = UIKit.UIViewController

      let bundle: Foundation.Bundle

      let name = "LaunchScreen"
      func validate() throws {

      }
    }
  }
}