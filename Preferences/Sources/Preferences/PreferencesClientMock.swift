import Foundation
import Shared

public extension PreferencesClientMock {
	convenience init(override: Bool) {
		self.init()
		underlyingPreferredAspectRatio = .fourByThree
		underlyingPreferredFlashMode = .on
		underlyingPreferredGalleryFilter = .all
		underlyingPreferredGrainPresence = GrainPresence.none
		underlyingPreferredShutterStyle = .dedicatedButton
		underlyingPreferredQuantization = .chromatic(.folia)
		underlyingShouldReverseCameraControls = false
		underlyingShouldEnableHaptics = true
		underlyingShouldIncludeScreenshotsInGallery = true
		underlyingPreferredLaunchDevicePosition = .front
		underlyingShouldAddCapturesToApplicationPhotoAlbum = true
		underlyingShouldEmbedLocationDataInCaptures = true
		underlyingShouldDoubleTapToFlipCamera = true
		underlyingShouldEnableSoundEffects = true
	}
}
