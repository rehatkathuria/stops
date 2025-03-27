// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// An album filled with your favourite photographs, as marked by you
  internal static let anAlbumFilledWithYourFavouritePhotographsAsMarkedByYou = L10n.tr("Localizable", "An album filled with your favourite photographs, as marked by you", fallback: "An album filled with your favourite photographs, as marked by you")
  /// An album that includes every photo taken with the front-facing camera
  internal static let anAlbumThatIncludesEveryPhotoTakenWithTheFrontFacingCamera = L10n.tr("Localizable", "An album that includes every photo taken with the front-facing camera", fallback: "An album that includes every photo taken with the front-facing camera")
  /// Entire Library
  internal static let entireLibrary = L10n.tr("Localizable", "Entire Library", fallback: "Entire Library")
  /// Favourites
  internal static let favourites = L10n.tr("Localizable", "Favourites", fallback: "Favourites")
  /// Gallery Permissions
  internal static let galleryPermissions = L10n.tr("Localizable", "Gallery Permissions", fallback: "Gallery Permissions")
  /// Grant Permissions
  internal static let grantPermissions = L10n.tr("Localizable", "Grant Permissions", fallback: "Grant Permissions")
  /// Hide Screenshots
  internal static let hideScreenshots = L10n.tr("Localizable", "Hide Screenshots", fallback: "Hide Screenshots")
  /// Screenshots will be visible in albums that include them
  internal static let screenshotsWillBeVisibleInAlbumsThatIncludeThem = L10n.tr("Localizable", "Screenshots will be visible in albums that include them", fallback: "Screenshots will be visible in albums that include them")
  /// Selfies
  internal static let selfies = L10n.tr("Localizable", "Selfies", fallback: "Selfies")
  /// Show Screenshots
  internal static let showScreenshots = L10n.tr("Localizable", "Show Screenshots", fallback: "Show Screenshots")
  /// The default album which includes every photo in your library
  internal static let theDefaultAlbumWhichIncludesEveryPhotoInYourLibrary = L10n.tr("Localizable", "The default album which includes every photo in your library", fallback: "The default album which includes every photo in your library")
  /// When viewing the entire album or your favourites, screenshots will be hidden
  internal static let whenViewingTheEntireAlbumOrYourFavouritesScreenshotsWillBeHidden = L10n.tr("Localizable", "When viewing the entire album or your favourites, screenshots will be hidden", fallback: "When viewing the entire album or your favourites, screenshots will be hidden")
  internal enum WeRequireGalleryPermissionToAllowYouToViewAndSavePhotos {
    /// We require gallery permission to allow you to view and save photos. Tap the button below to get started
    internal static let tapTheButtonBelowToGetStarted = L10n.tr("Localizable", "We require gallery permission to allow you to view and save photos. Tap the button below to get started", fallback: "We require gallery permission to allow you to view and save photos. Tap the button below to get started")
  }
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
