import AVFoundation
import Combine
import ComposableArchitecture
import Foundation
import Photos
import UIKit

public final class LivePermissionsClient: PermissionsClient {
	public var checkCameraPermissions: PermissionState {
		switch AVCaptureDevice.authorizationStatus(for: .video) {
		case .authorized: return .allowed
		case .denied, .restricted: return .denied
		case .notDetermined: return .undetermined
		@unknown default: return .undetermined
		}
	}

	public var microphonePermissions: PermissionState {
		switch AVCaptureDevice.authorizationStatus(for: .audio) {
		case .authorized: return .allowed
		case .denied, .restricted: return .denied
		case .notDetermined: return .undetermined
		@unknown default: return .undetermined
		}
	}
	
	public var requestCameraPermissions: EffectTask<PermissionState> {
		.future { promise in
			AVCaptureDevice.requestAccess(for: .video) { granted in
				promise(.success(granted ? .allowed : .denied))
			}
		}
	}
	
	public var requestMicrophonePermissions: EffectTask<PermissionState> {
		.future { promise in
			AVCaptureDevice.requestAccess(for: .audio) { granted in
				promise(.success(granted ? .allowed : .denied))
			}
		}
	}
	
	public var checkPhotoGalleryPermissions: PermissionState {
		switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
		case .authorized, .limited: return .allowed
		case .denied, .restricted: return .denied
		case .notDetermined: return .undetermined
		@unknown default: return .undetermined
		}
	}
	
	public var requestPhotoGalleryPermissions: EffectTask<PermissionState> {
		.task {
			let permission = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
			switch permission {
			case .authorized, .limited: return .allowed
			case .denied, .restricted: return .denied
			case .notDetermined: return .undetermined
			@unknown default: return .undetermined
			}
		}
	}
	
	public func registerForNotifications() {
#if !CAPTURE_EXTENSION
//		UIApplication.shared.registerForRemoteNotifications()
#endif
	}
	
	public func unregisterForNotifications() {
#if !CAPTURE_EXTENSION
//		UIApplication.shared.unregisterForRemoteNotifications()
#endif
	}
	
	public func openSystemSettings() {
#if !CAPTURE_EXTENSION
//		UIApplication.shared.open(
//			URL(string: UIApplication.openSettingsURLString)!
//		)
#endif
	}
		
}
