// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// Album
  internal static let album = L10n.tr("Localizable", "Album", fallback: "Album")
  /// Attach location metadata to captured images
  internal static let attachLocationMetadataToCapturedImages = L10n.tr("Localizable", "Attach location metadata to captured images", fallback: "Attach location metadata to captured images")
  /// Back
  internal static let back = L10n.tr("Localizable", "Back", fallback: "Back")
  /// Come say hello; we promise we don’t post reels
  internal static let comeSayHelloWePromiseWeDonTPostReels = L10n.tr("Localizable", "Come say hello; we promise we don’t post reels", fallback: "Come say hello; we promise we don’t post reels")
  /// Dedicated Button
  internal static let dedicatedButton = L10n.tr("Localizable", "Dedicated Button", fallback: "Dedicated Button")
  /// Enable subtle vibrations on button taps and animations
  internal static let enableSubtleVibrationsOnButtonTapsAndAnimations = L10n.tr("Localizable", "Enable subtle vibrations on button taps and animations", fallback: "Enable subtle vibrations on button taps and animations")
  /// Fetch and restore a previously purchased subscription from the App Store
  internal static let fetchAndRestoreAPreviouslyPurchasedSubscriptionFromTheAppStore = L10n.tr("Localizable", "Fetch and restore a previously purchased subscription from the App Store", fallback: "Fetch and restore a previously purchased subscription from the App Store")
  /// Front
  internal static let front = L10n.tr("Localizable", "Front", fallback: "Front")
  /// Got five seconds and stars to spare? We'd really appreciate a review
  internal static let gotFiveSecondsAndStarsToSpareWeDReallyAppreciateAReview = L10n.tr("Localizable", "Got five seconds and stars to spare? We'd really appreciate a review", fallback: "Got five seconds and stars to spare? We'd really appreciate a review")
  /// Haptics
  internal static let haptics = L10n.tr("Localizable", "Haptics", fallback: "Haptics")
  /// This app was localised with the help of Rehat Kathuria
  internal static let localisationExplainer = L10n.tr("Localizable", "Localisation Explainer", fallback: "This app was localised with the help of Rehat Kathuria")
  /// English
  internal static let localisationHeader = L10n.tr("Localizable", "Localisation Header", fallback: "English")
  /// Location
  internal static let location = L10n.tr("Localizable", "Location", fallback: "Location")
  /// Previews of upcoming features and other updates
  internal static let previewsOfUpcomingFeaturesAndOtherUpdates = L10n.tr("Localizable", "Previews of upcoming features and other updates", fallback: "Previews of upcoming features and other updates")
  /// Privacy Policy
  internal static let privacyPolicy = L10n.tr("Localizable", "Privacy Policy", fallback: "Privacy Policy")
  /// Stops does not collect, track or transmit any personal data
  internal static let privacyPolicyExplainer = L10n.tr("Localizable", "Privacy Policy Explainer", fallback: "Stops does not collect, track or transmit any personal data")
  /// Rate App
  internal static let rateApp = L10n.tr("Localizable", "Rate App", fallback: "Rate App")
  /// Restore Purchases
  internal static let restorePurchases = L10n.tr("Localizable", "Restore Purchases", fallback: "Restore Purchases")
  /// Reverse Camera Controls
  internal static let reverseCameraControls = L10n.tr("Localizable", "Reverse Camera Controls", fallback: "Reverse Camera Controls")
  /// Reverse the icon order to be the opposite direction of your language
  internal static let reverseTheIconOrderToBeTheOppositeDirectionOfYourLanguage = L10n.tr("Localizable", "Reverse the icon order to be the opposite direction of your language", fallback: "Reverse the icon order to be the opposite direction of your language")
  /// Select the camera you would like the app to start with when launching from scratch
  internal static let selectTheCameraYouWouldLikeTheAppToStartWithWhenLaunchingFromScratch = L10n.tr("Localizable", "Select the camera you would like the app to start with when launching from scratch", fallback: "Select the camera you would like the app to start with when launching from scratch")
  /// Settings
  internal static let settings = L10n.tr("Localizable", "Settings", fallback: "Settings")
  /// Shutter
  internal static let shutter = L10n.tr("Localizable", "Shutter", fallback: "Shutter")
  /// Starting Camera: 
  internal static let startingCamera = L10n.tr("Localizable", "Starting Camera: ", fallback: "Starting Camera: ")
  /// Stops Pro
  internal static let stopsPro = L10n.tr("Localizable", "Stops Pro", fallback: "Stops Pro")
  /// Upgrade to unlock custom icons and extra colour quantization profiles!
  internal static let stopsProExplainer = L10n.tr("Localizable", "Stops Pro Explainer", fallback: "Upgrade to unlock custom icons and extra colour quantization profiles!")
  /// Terms of Use
  internal static let termsOfUse = L10n.tr("Localizable", "Terms of Use", fallback: "Terms of Use")
  /// Using Stops, you agree to the standard Terms of Use issued by Apple
  internal static let termsOfUseExplainer = L10n.tr("Localizable", "Terms of Use Explainer", fallback: "Using Stops, you agree to the standard Terms of Use issued by Apple")
  /// Viewfinder
  internal static let viewfinder = L10n.tr("Localizable", "Viewfinder", fallback: "Viewfinder")
  /// When saving photos, add them to an album named “Stops”
  internal static let whenSavingPhotosAddThemToAnAlbumNamedStops = L10n.tr("Localizable", "When saving photos, add them to an album named “Stops”", fallback: "When saving photos, add them to an album named “Stops”")
  /// You can choose between using the viewfinder as a shutter or having a dedicated button
  internal static let youCanChooseBetweenUsingTheViewfinderAsAShutterOrHavingADedicatedButton = L10n.tr("Localizable", "You can choose between using the viewfinder as a shutter or having a dedicated button", fallback: "You can choose between using the viewfinder as a shutter or having a dedicated button")
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
