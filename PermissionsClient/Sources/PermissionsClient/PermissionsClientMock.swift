import AVFoundation
import Combine
import ComposableArchitecture
import Foundation
import Photos
import UIKit

extension PermissionsClientMock {
		public convenience init(override: Bool) {
			self.init()
			self.underlyingCheckPhotoGalleryPermissions = .undetermined
			self.underlyingCheckCameraPermissions = .undetermined
			self.underlyingRequestCameraPermissions = .fireAndForget {
				self.underlyingCheckCameraPermissions = .allowed
			}
			self.underlyingRequestPhotoGalleryPermissions = .fireAndForget {
				self.underlyingCheckPhotoGalleryPermissions = .allowed
			}
		}
	}
