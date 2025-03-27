// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
public typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum Asset {
  public enum IAPUpgradeExamples {
    public static let folia = ImageAsset(name: "folia")
    public static let monochrome = ImageAsset(name: "monochrome")
    public static let supergold = ImageAsset(name: "supergold")
  }
  public enum Phosphor {
    public static let appStoreLogo = ImageAsset(name: "app-store-logo")
    public static let article = ImageAsset(name: "article")
    public static let baby = ImageAsset(name: "baby")
    public static let bezierCurve = ImageAsset(name: "bezier-curve")
    public static let circlesFour = ImageAsset(name: "circles-four")
    public static let circlesThree = ImageAsset(name: "circles-three")
    public static let dotsNine = ImageAsset(name: "dots-nine")
    public static let dotsSix = ImageAsset(name: "dots-six")
    public static let eyeSlash = ImageAsset(name: "eye-slash")
    public static let flower = ImageAsset(name: "flower")
    public static let globe = ImageAsset(name: "globe")
    public static let grains = ImageAsset(name: "grains")
    public static let gridFour = ImageAsset(name: "grid-four")
    public static let heartStraight = ImageAsset(name: "heart-straight")
    public static let hexagon = ImageAsset(name: "hexagon")
    public static let images = ImageAsset(name: "images")
    public static let intersect = ImageAsset(name: "intersect")
    public static let linkBreak = ImageAsset(name: "link-break")
    public static let palette = ImageAsset(name: "palette")
    public static let pencilCircle = ImageAsset(name: "pencil-circle")
    public static let prohibitInset = ImageAsset(name: "prohibit-inset")
    public static let selectionBackground = ImageAsset(name: "selection-background")
    public static let sunHorizon = ImageAsset(name: "sun-horizon")
    public static let translate = ImageAsset(name: "translate")
    public static let videoCamera = ImageAsset(name: "video-camera")
    public static let warningDiamond = ImageAsset(name: "warning-diamond")
  }
  public enum PhosphorBold {
    public static let apertureBold = ImageAsset(name: "aperture-bold")
    public static let circleDashedBold = ImageAsset(name: "circle-dashed-bold")
    public static let exportBold = ImageAsset(name: "export-bold")
    public static let heartStraightBold = ImageAsset(name: "heart-straight-bold")
    public static let mountainsBold = ImageAsset(name: "mountains-bold")
    public static let trashSimpleBold = ImageAsset(name: "trash-simple-bold")
  }
  public enum PhosphorFill {
    public static let eyedropperSampleFill = ImageAsset(name: "eyedropper-sample-fill")
    public static let gearSixFill = ImageAsset(name: "gear-six-fill")
    public static let gitDiffFill = ImageAsset(name: "git-diff-fill")
    public static let heartStraightFill = ImageAsset(name: "heart-straight-fill")
    public static let layoutFill = ImageAsset(name: "layout-fill")
    public static let lightningAFill = ImageAsset(name: "lightning-a-fill")
    public static let lightningFill = ImageAsset(name: "lightning-fill")
    public static let lightningSlashFill = ImageAsset(name: "lightning-slash-fill")
    public static let numberSquareFiveFill = ImageAsset(name: "number-square-five-fill")
    public static let numberSquareFourFill = ImageAsset(name: "number-square-four-fill")
    public static let numberSquareOneFill = ImageAsset(name: "number-square-one-fill")
    public static let numberSquareThreeFill = ImageAsset(name: "number-square-three-fill")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public struct ImageAsset {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  public var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  public func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  public var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

public extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
public extension SwiftUI.Image {
  init(asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ImageAsset, label: Text) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

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
