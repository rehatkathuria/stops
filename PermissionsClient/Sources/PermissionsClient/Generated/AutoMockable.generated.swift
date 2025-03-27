// Generated using Sourcery 1.8.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all



import Foundation

#if canImport(AVFoundation)
import AVFoundation
#endif

#if canImport(Combine)
import Combine
#endif

#if canImport(ComposableArchitecture)
import ComposableArchitecture
#endif

#if canImport(CoreImage)
import CoreImage
#endif

#if canImport(UIKit)
import UIKit
#endif

public final class PermissionsClientMock: PermissionsClient, @unchecked Sendable {
    public init() {}
    public var checkCameraPermissions: PermissionState {
        get { return underlyingCheckCameraPermissions }
        set(value) { underlyingCheckCameraPermissions = value }
    }
    public var underlyingCheckCameraPermissions: PermissionState!
    public var microphonePermissions: PermissionState {
        get { return underlyingMicrophonePermissions }
        set(value) { underlyingMicrophonePermissions = value }
    }
    public var underlyingMicrophonePermissions: PermissionState!
    public var requestCameraPermissions: EffectTask<PermissionState> {
        get { return underlyingRequestCameraPermissions }
        set(value) { underlyingRequestCameraPermissions = value }
    }
    public var underlyingRequestCameraPermissions: EffectTask<PermissionState>!
    public var checkPhotoGalleryPermissions: PermissionState {
        get { return underlyingCheckPhotoGalleryPermissions }
        set(value) { underlyingCheckPhotoGalleryPermissions = value }
    }
    public var underlyingCheckPhotoGalleryPermissions: PermissionState!
    public var requestPhotoGalleryPermissions: EffectTask<PermissionState> {
        get { return underlyingRequestPhotoGalleryPermissions }
        set(value) { underlyingRequestPhotoGalleryPermissions = value }
    }
    public var underlyingRequestPhotoGalleryPermissions: EffectTask<PermissionState>!
    public var requestMicrophonePermissions: EffectTask<PermissionState> {
        get { return underlyingRequestMicrophonePermissions }
        set(value) { underlyingRequestMicrophonePermissions = value }
    }
    public var underlyingRequestMicrophonePermissions: EffectTask<PermissionState>!

    //MARK: - registerForNotifications

    public var registerForNotificationsCallsCount = 0
    public var registerForNotificationsCalled: Bool {
        return registerForNotificationsCallsCount > 0
    }
    public var registerForNotificationsClosure: (() -> Void)?
    public var registerForNotificationsQueue = DispatchQueue(label: "registerForNotificationsQueue")

    public func registerForNotifications() {
        registerForNotificationsQueue.sync {
            registerForNotificationsCallsCount += 1
            registerForNotificationsClosure?()
        }
    }

    //MARK: - unregisterForNotifications

    public var unregisterForNotificationsCallsCount = 0
    public var unregisterForNotificationsCalled: Bool {
        return unregisterForNotificationsCallsCount > 0
    }
    public var unregisterForNotificationsClosure: (() -> Void)?
    public var unregisterForNotificationsQueue = DispatchQueue(label: "unregisterForNotificationsQueue")

    public func unregisterForNotifications() {
        unregisterForNotificationsQueue.sync {
            unregisterForNotificationsCallsCount += 1
            unregisterForNotificationsClosure?()
        }
    }

    //MARK: - openSystemSettings

    public var openSystemSettingsCallsCount = 0
    public var openSystemSettingsCalled: Bool {
        return openSystemSettingsCallsCount > 0
    }
    public var openSystemSettingsClosure: (() -> Void)?
    public var openSystemSettingsQueue = DispatchQueue(label: "openSystemSettingsQueue")

    public func openSystemSettings() {
        openSystemSettingsQueue.sync {
            openSystemSettingsCallsCount += 1
            openSystemSettingsClosure?()
        }
    }

}
