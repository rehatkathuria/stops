import AVFoundation
import ComposableArchitecture
import Foundation
import Shared

public protocol PreferencesClient: AutoMockable {
	var preferredAspectRatio: AspectRatio { get }
	func setPreferredAspectRatio(_ aspectRatio: AspectRatio)
	
	var preferredContrast: ContrastPreset { get }
	func setPreferredContrast(_ contrast: ContrastPreset)

	var preferredFlashMode: AVCaptureDevice.FlashMode { get }
	func setPreferredFlashMode(_ flashMode: AVCaptureDevice.FlashMode)
	
	var preferredLaunchDevicePosition: AVCaptureDevice.Position { get }
	func setPreferredLaunchDevicePosition(_ position: AVCaptureDevice.Position)
	
	var preferredQuantization: Quantization { get }
	func setPreferredQuantization(_ quantization: Quantization)
	
	var preferredGalleryFilter: GalleryFilter { get }
	func setPreferredGalleryFilter(_ galleryFilter: GalleryFilter)
	
	var preferredGrainPresence: GrainPresence { get }
	func setPreferredGrainPresence(_ grainPresence: GrainPresence)
	
	var preferredShutterStyle: ShutterStyle { get }
	func setPreferredShutterStyle(_ style: ShutterStyle)
	
	var preferredTemperature: TemperaturePreset { get }
	func setPreferredTemperature(_ temperature: TemperaturePreset)
	
	var shouldAddCapturesToApplicationPhotoAlbum: Bool { get }
	func setShouldAddCapturesToApplicationPhotoAlbum(_ bool: Bool)
	
	var shouldDoubleTapToFlipCamera: Bool { get }
	func setShouldDoubleTapToFlipCamera(_ bool: Bool)
	
	var shouldEmbedLocationDataInCaptures: Bool { get }
	func setShouldEmbedLocationDataInCaptures(_ bool: Bool)
	
	var shouldEnableHaptics: Bool { get }
	func setShouldEnableHaptics(_ bool: Bool)
	
	var shouldEnableSoundEffects: Bool { get }
	func setShouldEnableSoundEffects(_ bool: Bool)
	
	var shouldReverseCameraControls: Bool { get }
	func setshouldReverseCameraControls(_ shouldReverse: Bool)

	var shouldIncludeScreenshotsInGallery: Bool { get }
	func setShouldIncludeScreenshotsInGallery(_ shouldInclude: Bool)
	
	var lastKnownFrontFacingZoomValue: Float { get }
	func setlastKnownFrontFacingZoomValue(_ newValue: Float)

	var lastKnownBackFacingZoomValue: Float { get }
	func setlastKnownBackFacingZoomValue(_ newValue: Float)
}


public class LivePreferencesClient: PreferencesClient {
	
//	public static var defaults = UserDefaults.standard
	
	public enum Keys: String {
		case lastKnownFrontFacingZoomValue
		case lastKnownBackFacingZoomValue
		
		case preferredAspectRatio
		case preferredContrast
		case preferredFlashMode
		case preferredQuantization
		case preferredGalleryFilter
		case preferredGrainPresence
		case preferredLaunchDevicePosition
		case preferredShutterStyle
		case preferredTemperature
		
		case shouldAddCapturesToApplicationPhotoAlbum
		case shouldDisableDoubleTapToFlipCamera
		case shouldDisableHaptics
		case shouldDisableSounds
		case shouldEmbedLocationDataInCaptures
		case shouldReverseCameraControls
		case shouldIncludeScreenshotsInGallery
	}
	
	/// MARK: - Aspect Ratio
	public var preferredAspectRatio: AspectRatio {
//		if let key = LivePreferencesClient.defaults.string(forKey: Keys.preferredAspectRatio.rawValue), let created = AspectRatio(rawValue: key) {
//			return created
//		}
//		else {
			return .fourByThree
//		}
	}
	
	public func setPreferredAspectRatio(_ aspectRatio: AspectRatio) {
//		LivePreferencesClient.defaults.set(aspectRatio.rawValue, forKey: Keys.preferredAspectRatio.rawValue)
	}
	
	/// MARK: - Contrast
	
	public var preferredContrast: ContrastPreset {
//		if let key = LivePreferencesClient.defaults.string(forKey: Keys.preferredContrast.rawValue), let created = ContrastPreset(rawValue: key) {
//			return created
//		}
//		else {
			return .neutral
//		}
	}
	
	public func setPreferredContrast(_ contrast: ContrastPreset) {
//		LivePreferencesClient.defaults.set(contrast.rawValue, forKey: Keys.preferredContrast.rawValue)
	}
	
	/// MARK: - Filter
	
	public var preferredQuantization: Quantization {
//		if let key = LivePreferencesClient.defaults.string(forKey: Keys.preferredQuantization.rawValue), let created = Quantization.quantizationFromName(key) {
//			return created
//		}
//		else {
			return .chromatic(.tonachrome)
//		}
	}
	
	public func setPreferredQuantization(_ quantization: Quantization) {
//		LivePreferencesClient.defaults.set(quantization.name, forKey: Keys.preferredQuantization.rawValue)
	}
	
	public var preferredLaunchDevicePosition: AVCaptureDevice.Position {
//		if let created = AVCaptureDevice.Position(rawValue: LivePreferencesClient.defaults.integer(forKey: Keys.preferredLaunchDevicePosition.rawValue)) {
//			return created
//		}
//		else {
			return .back
//		}
	}
	
	public func setPreferredLaunchDevicePosition(_ position: AVCaptureDevice.Position) {
//		LivePreferencesClient.defaults.set(position.rawValue, forKey: Keys.preferredLaunchDevicePosition.rawValue)
	}

	/// MARK: - Flash Mode
	
	public var preferredFlashMode: AVCaptureDevice.FlashMode {
//		if let created = AVCaptureDevice.FlashMode(rawValue: LivePreferencesClient.defaults.integer(forKey: Keys.preferredFlashMode.rawValue)) {
//			return created
//		}
//		else {
			return .off
//		}
	}
	
	public func setPreferredFlashMode(_ flashMode: AVCaptureDevice.FlashMode) {
//		LivePreferencesClient.defaults.set(flashMode.rawValue, forKey: Keys.preferredFlashMode.rawValue)
	}
	
	/// MARK: - Gallery Filter
	
	public var preferredGalleryFilter: GalleryFilter {
//		if let rawValue = LivePreferencesClient.defaults.string(forKey: Keys.preferredGalleryFilter.rawValue),
//			 let created = GalleryFilter(rawValue: rawValue) { return created }
//		else {
			return .all
//		}
	}
	
	public func setPreferredGalleryFilter(_ galleryFilter: GalleryFilter) {
//		LivePreferencesClient.defaults.set(galleryFilter.rawValue, forKey: Keys.preferredGalleryFilter.rawValue)
	}
	
	
	/// MARK: - Grain Presence
	
	public var preferredGrainPresence: GrainPresence {
//		if let key = LivePreferencesClient.defaults.string(forKey: Keys.preferredGrainPresence.rawValue), let created = GrainPresence(rawValue: key) {
//			return created
//		}
//		else {
			return .none
//		}
	}
	
	public func setPreferredGrainPresence(_ grainPresence: GrainPresence) {
//		LivePreferencesClient.defaults.set(grainPresence.rawValue, forKey: Keys.preferredGrainPresence.rawValue)
	}
	
	/// MARK: - Settings
	
	public var shouldAddCapturesToApplicationPhotoAlbum: Bool {
		false
//		LivePreferencesClient.defaults.bool(forKey: Keys.shouldAddCapturesToApplicationPhotoAlbum.rawValue)
	}
	
	public func setShouldAddCapturesToApplicationPhotoAlbum(_ bool: Bool) {
//		LivePreferencesClient.defaults.set(bool, forKey: Keys.shouldAddCapturesToApplicationPhotoAlbum.rawValue)
	}
	
	public var shouldDoubleTapToFlipCamera: Bool {
		false
//		!LivePreferencesClient.defaults.bool(forKey: Keys.shouldDisableDoubleTapToFlipCamera.rawValue)
	}
	
	public func setShouldDoubleTapToFlipCamera(_ bool: Bool) {
//		LivePreferencesClient.defaults.set(!bool, forKey: Keys.shouldDisableDoubleTapToFlipCamera.rawValue)
	}
	
	public var shouldEmbedLocationDataInCaptures: Bool {
		false
//		LivePreferencesClient.defaults.bool(forKey: Keys.shouldEmbedLocationDataInCaptures.rawValue)
	}
	
	public func setShouldEmbedLocationDataInCaptures(_ bool: Bool) {
//		LivePreferencesClient.defaults.set(bool, forKey: Keys.shouldEmbedLocationDataInCaptures.rawValue)
	}
	
	public var shouldEnableHaptics: Bool {
		false
//		!LivePreferencesClient.defaults.bool(forKey: Keys.shouldDisableHaptics.rawValue)
	}
	
	public func setShouldEnableHaptics(_ bool: Bool) {
//		LivePreferencesClient.defaults.set(!bool, forKey: Keys.shouldDisableHaptics.rawValue)
	}
	
	public var shouldEnableSoundEffects: Bool {
		false
//		!LivePreferencesClient.defaults.bool(forKey: Keys.shouldDisableSounds.rawValue)
	}
	
	public func setShouldEnableSoundEffects(_ bool: Bool) {
//		LivePreferencesClient.defaults.set(!bool, forKey: Keys.shouldDisableSounds.rawValue)
	}

	public var preferredShutterStyle: ShutterStyle {
//		if let key = LivePreferencesClient.defaults.string(forKey: Keys.preferredShutterStyle.rawValue), let created = ShutterStyle(rawValue: key) {
//			return created
//		}
//		else {
			return .dedicatedButton
//		}
	}
	
	public func setPreferredShutterStyle(_ style: ShutterStyle) {
//		LivePreferencesClient.defaults.set(style.rawValue, forKey: Keys.preferredShutterStyle.rawValue)
	}
	
	public var shouldReverseCameraControls: Bool {
		false
//		LivePreferencesClient.defaults.bool(forKey: Keys.shouldReverseCameraControls.rawValue)
	}
	
	public func setshouldReverseCameraControls(_ shouldReverse: Bool) {
//		LivePreferencesClient.defaults.set(shouldReverse, forKey: Keys.shouldReverseCameraControls.rawValue)
	}
	
	public var shouldIncludeScreenshotsInGallery: Bool {
		false
//		LivePreferencesClient.defaults.bool(forKey: Keys.shouldIncludeScreenshotsInGallery.rawValue)
	}
	
	public func setShouldIncludeScreenshotsInGallery(_ shouldInclude: Bool) {
//		LivePreferencesClient.defaults.set(shouldInclude, forKey: Keys.shouldIncludeScreenshotsInGallery.rawValue)
	}
	
	/// MARK: - Temperature
	
	public var preferredTemperature: TemperaturePreset {
//		if let key = LivePreferencesClient.defaults.string(forKey: Keys.preferredTemperature.rawValue), let created = TemperaturePreset(rawValue: key) {
//			return created
//		}
//		else {
			return .neutral
//		}
	}
	
	public func setPreferredTemperature(_ temperature: TemperaturePreset) {
//		LivePreferencesClient.defaults.set(temperature.rawValue, forKey: Keys.preferredTemperature.rawValue)
	}
	
	/// MARK: - Zoom
	
	public var lastKnownBackFacingZoomValue: Float {
		1
//		let defaultsValue = Self.defaults.float(forKey: Keys.lastKnownBackFacingZoomValue.rawValue)
//		if defaultsValue != 0 { return defaultsValue }
//		else { return 1.0 }
	}
	
	public func setlastKnownBackFacingZoomValue(_ newValue: Float) {
//		Self.defaults.setValue(newValue, forKey: Keys.lastKnownBackFacingZoomValue.rawValue)
	}
	
	public var lastKnownFrontFacingZoomValue: Float {
		1
//		let defaultsValue = Self.defaults.float(forKey: Keys.lastKnownFrontFacingZoomValue.rawValue)
//		if defaultsValue != 0 { return defaultsValue }
//		else { return 1.0 }
	}
	
	public func setlastKnownFrontFacingZoomValue(_ newValue: Float) {
//		Self.defaults.setValue(newValue, forKey: Keys.lastKnownFrontFacingZoomValue.rawValue)
	}
	
	public init() { }
}

public enum PreferencesClientKey: DependencyKey {
	public static let liveValue: PreferencesClient = LivePreferencesClient()
	public static var testValue: PreferencesClient = PreferencesClientMock(override: true)
}

public extension DependencyValues {
	var preferencesClient: PreferencesClient {
		get { self[PreferencesClientKey.self] }
		set { self[PreferencesClientKey.self] = newValue }
	}
}


