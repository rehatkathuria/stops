// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// 1 Month
  internal static let _1Month = L10n.tr("Localizable", "1 Month", fallback: "1 Month")
  /// 12 Months
  internal static let _12Months = L10n.tr("Localizable", "12 Months", fallback: "12 Months")
  /// annually
  internal static let annually = L10n.tr("Localizable", "Annually", fallback: "annually")
  /// Best Value
  internal static let bestValue = L10n.tr("Localizable", "Best Value", fallback: "Best Value")
  /// Continue
  internal static let `continue` = L10n.tr("Localizable", "Continue", fallback: "Continue")
  /// Custom App Icons
  internal static let customAppIcons = L10n.tr("Localizable", "Custom App Icons", fallback: "Custom App Icons")
  /// Folia
  internal static let folia = L10n.tr("Localizable", "Folia", fallback: "Folia")
  /// Fun!
  internal static let fun = L10n.tr("Localizable", "Fun!", fallback: "Fun!")
  /// Monochrome
  internal static let monochrome = L10n.tr("Localizable", "Monochrome", fallback: "Monochrome")
  /// monthly
  internal static let monthly = L10n.tr("Localizable", "Monthly", fallback: "monthly")
  /// Most Popular
  internal static let mostPopular = L10n.tr("Localizable", "Most Popular", fallback: "Most Popular")
  /// /mo
  internal static let perMonth = L10n.tr("Localizable", "perMonth", fallback: "/mo")
  /// /year
  internal static let perYear = L10n.tr("Localizable", "perYear", fallback: "/year")
  /// Quantization Algorithms
  internal static let quantizationAlgorithms = L10n.tr("Localizable", "Quantization Algorithms", fallback: "Quantization Algorithms")
  /// Quirky
  internal static let quirky = L10n.tr("Localizable", "Quirky", fallback: "Quirky")
  /// savings
  internal static let savings = L10n.tr("Localizable", "Savings", fallback: "savings")
  /// Supergold
  internal static let supergold = L10n.tr("Localizable", "Supergold", fallback: "Supergold")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
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
