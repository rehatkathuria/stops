import Combine
import ComposableArchitecture
import Foundation
import Shared

@frozen
public enum PermissionState {
	case undetermined, allowed, denied
}

public protocol PermissionsClient: AutoMockable {
	var checkCameraPermissions: PermissionState { get }
	var microphonePermissions: PermissionState { get }
	var requestCameraPermissions: EffectTask<PermissionState> { get }
	var checkPhotoGalleryPermissions: PermissionState { get }
	var requestPhotoGalleryPermissions: EffectTask<PermissionState> { get }
	var requestMicrophonePermissions: EffectTask<PermissionState> { get }
	func registerForNotifications()
	func unregisterForNotifications()
	func openSystemSettings()
}

private enum PermissionsClientKey: DependencyKey {
	static let liveValue: PermissionsClient = LivePermissionsClient()
	static var testValue: PermissionsClient = PermissionsClientMock(override: true)
}

public extension DependencyValues {
	var permissionsClient: PermissionsClient {
		get { self[PermissionsClientKey.self] }
		set { self[PermissionsClientKey.self] = newValue }
	}
}
