// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum Loc {
  internal enum About {
    /// Buy me a coffee
    internal static let buyMeACoffee = Loc.tr("About", "buyMeACoffee", fallback: "Buy me a coffee")
    /// Manage App Store Connect subscription pricing and territories.
    internal static let description = Loc.tr("About", "description", fallback: "Manage App Store Connect subscription pricing and territories.")
    /// AboutView
    internal static let done = Loc.tr("About", "done", fallback: "Done")
    /// Email me
    internal static let emailMe = Loc.tr("About", "emailMe", fallback: "Email me")
    /// If Price Wizard saves you time, I'd love to hear from you - or you can buy me a coffee to say thanks.
    internal static let supportMessage = Loc.tr("About", "supportMessage", fallback: "If Price Wizard saves you time, I'd love to hear from you - or you can buy me a coffee to say thanks.")
  }
  internal enum AppsList {
    /// Error
    internal static let error = Loc.tr("AppsList", "error", fallback: "Error")
    /// Loading
    internal static let loading = Loc.tr("AppsList", "loading", fallback: "Loading")
    /// Fetching your apps…
    internal static let loadingDescription = Loc.tr("AppsList", "loadingDescription", fallback: "Fetching your apps…")
    /// AppsListView
    internal static let title = Loc.tr("AppsList", "title", fallback: "Apps")
  }
  internal enum Auth {
    /// Connect
    internal static let connect = Loc.tr("Auth", "connect", fallback: "Connect")
    /// Enter your API key details from App Store Connect > Users and Access > Integrations.
    internal static let instructions = Loc.tr("Auth", "instructions", fallback: "Enter your API key details from App Store Connect > Users and Access > Integrations.")
    /// xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    internal static let issuerIdPlaceholder = Loc.tr("Auth", "issuerIdPlaceholder", fallback: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx")
    /// XXXXXXXXXX
    internal static let keyIdPlaceholder = Loc.tr("Auth", "keyIdPlaceholder", fallback: "XXXXXXXXXX")
    /// Select AuthKey_XXXXXXXX.p8
    internal static let selectP8 = Loc.tr("Auth", "selectP8", fallback: "Select AuthKey_XXXXXXXX.p8")
    /// AuthSetupView
    internal static let title = Loc.tr("Auth", "title", fallback: "App Store Connect API")
  }
  internal enum ContentView {
    /// ContentView toolbar
    internal static let aboutTooltip = Loc.tr("ContentView", "aboutTooltip", fallback: "About Price Wizard")
    /// Log Out
    internal static let logOut = Loc.tr("ContentView", "logOut", fallback: "Log Out")
  }
  internal enum PriceSettings {
    /// Apply to App Store Connect
    internal static let applyToAppStoreConnect = Loc.tr("PriceSettings", "applyToAppStoreConnect", fallback: "Apply to App Store Connect")
    /// Base Price
    internal static let basePrice = Loc.tr("PriceSettings", "basePrice", fallback: "Base Price")
    /// Currency
    internal static let currency = Loc.tr("PriceSettings", "currency", fallback: "Currency")
    /// Current price
    internal static let currentPrice = Loc.tr("PriceSettings", "currentPrice", fallback: "Current price")
    /// Done
    internal static let done = Loc.tr("PriceSettings", "done", fallback: "Done")
    /// Error
    internal static let error = Loc.tr("PriceSettings", "error", fallback: "Error")
    /// Index Mode
    internal static let indexMode = Loc.tr("PriceSettings", "indexMode", fallback: "Index Mode")
    /// Loading price points…
    internal static let loadingPricePoints = Loc.tr("PriceSettings", "loadingPricePoints", fallback: "Loading price points…")
    /// Loading price points…
    internal static let loadingPricePointsProgress = Loc.tr("PriceSettings", "loadingPricePointsProgress", fallback: "Loading price points…")
    /// Loading price tiers…
    internal static let loadingPriceTiers = Loc.tr("PriceSettings", "loadingPriceTiers", fallback: "Loading price tiers…")
    /// Mode
    internal static let mode = Loc.tr("PriceSettings", "mode", fallback: "Mode")
    /// New Price
    internal static let newPrice = Loc.tr("PriceSettings", "newPrice", fallback: "New Price")
    /// New Price (USD)
    internal static let newPriceUSD = Loc.tr("PriceSettings", "newPriceUSD", fallback: "New Price (USD)")
    /// Next scheduled change: %@
    internal static func nextScheduledChange(_ p1: Any) -> String {
      return Loc.tr("PriceSettings", "nextScheduledChange", String(describing: p1), fallback: "Next scheduled change: %@")
    }
    /// No future scheduled changes
    internal static let noFutureScheduledChanges = Loc.tr("PriceSettings", "noFutureScheduledChanges", fallback: "No future scheduled changes")
    /// No price points available
    internal static let noPricePointsAvailable = Loc.tr("PriceSettings", "noPricePointsAvailable", fallback: "No price points available")
    /// No price points available for this subscription.
    internal static let noPricePointsForSubscription = Loc.tr("PriceSettings", "noPricePointsForSubscription", fallback: "No price points available for this subscription.")
    /// OK
    internal static let ok = Loc.tr("PriceSettings", "ok", fallback: "OK")
    /// Preserve current price for existing subscribers
    internal static let preserveCurrentPrice = Loc.tr("PriceSettings", "preserveCurrentPrice", fallback: "Preserve current price for existing subscribers")
    /// Preview
    internal static let preview = Loc.tr("PriceSettings", "preview", fallback: "Preview")
    /// Price
    internal static let price = Loc.tr("PriceSettings", "price", fallback: "Price")
    /// Price Change Options
    internal static let priceChangeOptions = Loc.tr("PriceSettings", "priceChangeOptions", fallback: "Price Change Options")
    /// Price (%@)
    internal static func priceCurrency(_ p1: Any) -> String {
      return Loc.tr("PriceSettings", "priceCurrency", String(describing: p1), fallback: "Price (%@)")
    }
    /// Select…
    internal static let select = Loc.tr("PriceSettings", "select", fallback: "Select…")
    /// Select Price for %@
    internal static func selectPriceFor(_ p1: Any) -> String {
      return Loc.tr("PriceSettings", "selectPriceFor", String(describing: p1), fallback: "Select Price for %@")
    }
    /// PriceSettingsView
    internal static let selectSubscription = Loc.tr("PriceSettings", "selectSubscription", fallback: "Select a Subscription")
    /// Choose a subscription from the list to configure its prices.
    internal static let selectSubscriptionDescription = Loc.tr("PriceSettings", "selectSubscriptionDescription", fallback: "Choose a subscription from the list to configure its prices.")
    /// Start date
    internal static let startDate = Loc.tr("PriceSettings", "startDate", fallback: "Start date")
    /// This date is already used by a scheduled price change; choose another date.
    internal static let startDateConflict = Loc.tr("PriceSettings", "startDateConflict", fallback: "This date is already used by a scheduled price change; choose another date.")
    /// Territory
    internal static let territory = Loc.tr("PriceSettings", "territory", fallback: "Territory")
    /// %@ of %@
    internal static func tierProgress(_ p1: Any, _ p2: Any) -> String {
      return Loc.tr("PriceSettings", "tierProgress", String(describing: p1), String(describing: p2), fallback: "%@ of %@")
    }
  }
  internal enum Subscriptions {
    /// Error
    internal static let error = Loc.tr("Subscriptions", "error", fallback: "Error")
    /// Loading subscriptions…
    internal static let loadingSubscriptions = Loc.tr("Subscriptions", "loadingSubscriptions", fallback: "Loading subscriptions…")
    /// Monthly
    internal static let monthly = Loc.tr("Subscriptions", "monthly", fallback: "Monthly")
    /// No Subscriptions
    internal static let noSubscriptions = Loc.tr("Subscriptions", "noSubscriptions", fallback: "No Subscriptions")
    /// This app has no in-app subscriptions.
    internal static let noSubscriptionsDescription = Loc.tr("Subscriptions", "noSubscriptionsDescription", fallback: "This app has no in-app subscriptions.")
    /// Select an App
    internal static let selectApp = Loc.tr("Subscriptions", "selectApp", fallback: "Select an App")
    /// Choose an app from the sidebar to see its subscriptions.
    internal static let selectAppDescription = Loc.tr("Subscriptions", "selectAppDescription", fallback: "Choose an app from the sidebar to see its subscriptions.")
    /// 6 months
    internal static let sixMonths = Loc.tr("Subscriptions", "sixMonths", fallback: "6 months")
    /// 3 months
    internal static let threeMonths = Loc.tr("Subscriptions", "threeMonths", fallback: "3 months")
    /// SubscriptionsDetailView
    internal static let title = Loc.tr("Subscriptions", "title", fallback: "Subscriptions")
    /// 2 months
    internal static let twoMonths = Loc.tr("Subscriptions", "twoMonths", fallback: "2 months")
    /// Unknown
    internal static let unknown = Loc.tr("Subscriptions", "unknown", fallback: "Unknown")
    /// Weekly
    internal static let weekly = Loc.tr("Subscriptions", "weekly", fallback: "Weekly")
    /// Yearly
    internal static let yearly = Loc.tr("Subscriptions", "yearly", fallback: "Yearly")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Loc {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
