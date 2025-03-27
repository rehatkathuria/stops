// Generated using Sourcery 1.8.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Shared


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

public final class PreferencesClientMock: PreferencesClient, @unchecked Sendable {
    public init() {}
    public var preferredAspectRatio: AspectRatio {
        get { return underlyingPreferredAspectRatio }
        set(value) { underlyingPreferredAspectRatio = value }
    }
    public var underlyingPreferredAspectRatio: AspectRatio!
    public var preferredContrast: ContrastPreset {
        get { return underlyingPreferredContrast }
        set(value) { underlyingPreferredContrast = value }
    }
    public var underlyingPreferredContrast: ContrastPreset!
    public var preferredFlashMode: AVCaptureDevice.FlashMode {
        get { return underlyingPreferredFlashMode }
        set(value) { underlyingPreferredFlashMode = value }
    }
    public var underlyingPreferredFlashMode: AVCaptureDevice.FlashMode!
    public var preferredLaunchDevicePosition: AVCaptureDevice.Position {
        get { return underlyingPreferredLaunchDevicePosition }
        set(value) { underlyingPreferredLaunchDevicePosition = value }
    }
    public var underlyingPreferredLaunchDevicePosition: AVCaptureDevice.Position!
    public var preferredQuantization: Quantization {
        get { return underlyingPreferredQuantization }
        set(value) { underlyingPreferredQuantization = value }
    }
    public var underlyingPreferredQuantization: Quantization!
    public var preferredGalleryFilter: GalleryFilter {
        get { return underlyingPreferredGalleryFilter }
        set(value) { underlyingPreferredGalleryFilter = value }
    }
    public var underlyingPreferredGalleryFilter: GalleryFilter!
    public var preferredGrainPresence: GrainPresence {
        get { return underlyingPreferredGrainPresence }
        set(value) { underlyingPreferredGrainPresence = value }
    }
    public var underlyingPreferredGrainPresence: GrainPresence!
    public var preferredShutterStyle: ShutterStyle {
        get { return underlyingPreferredShutterStyle }
        set(value) { underlyingPreferredShutterStyle = value }
    }
    public var underlyingPreferredShutterStyle: ShutterStyle!
    public var preferredTemperature: TemperaturePreset {
        get { return underlyingPreferredTemperature }
        set(value) { underlyingPreferredTemperature = value }
    }
    public var underlyingPreferredTemperature: TemperaturePreset!
    public var shouldAddCapturesToApplicationPhotoAlbum: Bool {
        get { return underlyingShouldAddCapturesToApplicationPhotoAlbum }
        set(value) { underlyingShouldAddCapturesToApplicationPhotoAlbum = value }
    }
    public var underlyingShouldAddCapturesToApplicationPhotoAlbum: Bool!
    public var shouldDoubleTapToFlipCamera: Bool {
        get { return underlyingShouldDoubleTapToFlipCamera }
        set(value) { underlyingShouldDoubleTapToFlipCamera = value }
    }
    public var underlyingShouldDoubleTapToFlipCamera: Bool!
    public var shouldEmbedLocationDataInCaptures: Bool {
        get { return underlyingShouldEmbedLocationDataInCaptures }
        set(value) { underlyingShouldEmbedLocationDataInCaptures = value }
    }
    public var underlyingShouldEmbedLocationDataInCaptures: Bool!
    public var shouldEnableHaptics: Bool {
        get { return underlyingShouldEnableHaptics }
        set(value) { underlyingShouldEnableHaptics = value }
    }
    public var underlyingShouldEnableHaptics: Bool!
    public var shouldEnableSoundEffects: Bool {
        get { return underlyingShouldEnableSoundEffects }
        set(value) { underlyingShouldEnableSoundEffects = value }
    }
    public var underlyingShouldEnableSoundEffects: Bool!
    public var shouldReverseCameraControls: Bool {
        get { return underlyingShouldReverseCameraControls }
        set(value) { underlyingShouldReverseCameraControls = value }
    }
    public var underlyingShouldReverseCameraControls: Bool!
    public var shouldIncludeScreenshotsInGallery: Bool {
        get { return underlyingShouldIncludeScreenshotsInGallery }
        set(value) { underlyingShouldIncludeScreenshotsInGallery = value }
    }
    public var underlyingShouldIncludeScreenshotsInGallery: Bool!
    public var lastKnownFrontFacingZoomValue: Float {
        get { return underlyingLastKnownFrontFacingZoomValue }
        set(value) { underlyingLastKnownFrontFacingZoomValue = value }
    }
    public var underlyingLastKnownFrontFacingZoomValue: Float!
    public var lastKnownBackFacingZoomValue: Float {
        get { return underlyingLastKnownBackFacingZoomValue }
        set(value) { underlyingLastKnownBackFacingZoomValue = value }
    }
    public var underlyingLastKnownBackFacingZoomValue: Float!

    //MARK: - setPreferredAspectRatio

    public var setPreferredAspectRatioCallsCount = 0
    public var setPreferredAspectRatioCalled: Bool {
        return setPreferredAspectRatioCallsCount > 0
    }
    public var setPreferredAspectRatioReceivedAspectRatio: AspectRatio?
    public var setPreferredAspectRatioClosure: ((AspectRatio) -> Void)?
    public var setPreferredAspectRatioQueue = DispatchQueue(label: "setPreferredAspectRatioQueue")

    public func setPreferredAspectRatio(_ aspectRatio: AspectRatio) {
        setPreferredAspectRatioQueue.sync {
            setPreferredAspectRatioCallsCount += 1
        setPreferredAspectRatioReceivedAspectRatio = aspectRatio
            setPreferredAspectRatioClosure?(aspectRatio)
        }
    }

    //MARK: - setPreferredContrast

    public var setPreferredContrastCallsCount = 0
    public var setPreferredContrastCalled: Bool {
        return setPreferredContrastCallsCount > 0
    }
    public var setPreferredContrastReceivedContrast: ContrastPreset?
    public var setPreferredContrastClosure: ((ContrastPreset) -> Void)?
    public var setPreferredContrastQueue = DispatchQueue(label: "setPreferredContrastQueue")

    public func setPreferredContrast(_ contrast: ContrastPreset) {
        setPreferredContrastQueue.sync {
            setPreferredContrastCallsCount += 1
        setPreferredContrastReceivedContrast = contrast
            setPreferredContrastClosure?(contrast)
        }
    }

    //MARK: - setPreferredFlashMode

    public var setPreferredFlashModeCallsCount = 0
    public var setPreferredFlashModeCalled: Bool {
        return setPreferredFlashModeCallsCount > 0
    }
    public var setPreferredFlashModeReceivedFlashMode: AVCaptureDevice.FlashMode?
    public var setPreferredFlashModeClosure: ((AVCaptureDevice.FlashMode) -> Void)?
    public var setPreferredFlashModeQueue = DispatchQueue(label: "setPreferredFlashModeQueue")

    public func setPreferredFlashMode(_ flashMode: AVCaptureDevice.FlashMode) {
        setPreferredFlashModeQueue.sync {
            setPreferredFlashModeCallsCount += 1
        setPreferredFlashModeReceivedFlashMode = flashMode
            setPreferredFlashModeClosure?(flashMode)
        }
    }

    //MARK: - setPreferredLaunchDevicePosition

    public var setPreferredLaunchDevicePositionCallsCount = 0
    public var setPreferredLaunchDevicePositionCalled: Bool {
        return setPreferredLaunchDevicePositionCallsCount > 0
    }
    public var setPreferredLaunchDevicePositionReceivedPosition: AVCaptureDevice.Position?
    public var setPreferredLaunchDevicePositionClosure: ((AVCaptureDevice.Position) -> Void)?
    public var setPreferredLaunchDevicePositionQueue = DispatchQueue(label: "setPreferredLaunchDevicePositionQueue")

    public func setPreferredLaunchDevicePosition(_ position: AVCaptureDevice.Position) {
        setPreferredLaunchDevicePositionQueue.sync {
            setPreferredLaunchDevicePositionCallsCount += 1
        setPreferredLaunchDevicePositionReceivedPosition = position
            setPreferredLaunchDevicePositionClosure?(position)
        }
    }

    //MARK: - setPreferredQuantization

    public var setPreferredQuantizationCallsCount = 0
    public var setPreferredQuantizationCalled: Bool {
        return setPreferredQuantizationCallsCount > 0
    }
    public var setPreferredQuantizationReceivedQuantization: Quantization?
    public var setPreferredQuantizationClosure: ((Quantization) -> Void)?
    public var setPreferredQuantizationQueue = DispatchQueue(label: "setPreferredQuantizationQueue")

    public func setPreferredQuantization(_ quantization: Quantization) {
        setPreferredQuantizationQueue.sync {
            setPreferredQuantizationCallsCount += 1
        setPreferredQuantizationReceivedQuantization = quantization
            setPreferredQuantizationClosure?(quantization)
        }
    }

    //MARK: - setPreferredGalleryFilter

    public var setPreferredGalleryFilterCallsCount = 0
    public var setPreferredGalleryFilterCalled: Bool {
        return setPreferredGalleryFilterCallsCount > 0
    }
    public var setPreferredGalleryFilterReceivedGalleryFilter: GalleryFilter?
    public var setPreferredGalleryFilterClosure: ((GalleryFilter) -> Void)?
    public var setPreferredGalleryFilterQueue = DispatchQueue(label: "setPreferredGalleryFilterQueue")

    public func setPreferredGalleryFilter(_ galleryFilter: GalleryFilter) {
        setPreferredGalleryFilterQueue.sync {
            setPreferredGalleryFilterCallsCount += 1
        setPreferredGalleryFilterReceivedGalleryFilter = galleryFilter
            setPreferredGalleryFilterClosure?(galleryFilter)
        }
    }

    //MARK: - setPreferredGrainPresence

    public var setPreferredGrainPresenceCallsCount = 0
    public var setPreferredGrainPresenceCalled: Bool {
        return setPreferredGrainPresenceCallsCount > 0
    }
    public var setPreferredGrainPresenceReceivedGrainPresence: GrainPresence?
    public var setPreferredGrainPresenceClosure: ((GrainPresence) -> Void)?
    public var setPreferredGrainPresenceQueue = DispatchQueue(label: "setPreferredGrainPresenceQueue")

    public func setPreferredGrainPresence(_ grainPresence: GrainPresence) {
        setPreferredGrainPresenceQueue.sync {
            setPreferredGrainPresenceCallsCount += 1
        setPreferredGrainPresenceReceivedGrainPresence = grainPresence
            setPreferredGrainPresenceClosure?(grainPresence)
        }
    }

    //MARK: - setPreferredShutterStyle

    public var setPreferredShutterStyleCallsCount = 0
    public var setPreferredShutterStyleCalled: Bool {
        return setPreferredShutterStyleCallsCount > 0
    }
    public var setPreferredShutterStyleReceivedStyle: ShutterStyle?
    public var setPreferredShutterStyleClosure: ((ShutterStyle) -> Void)?
    public var setPreferredShutterStyleQueue = DispatchQueue(label: "setPreferredShutterStyleQueue")

    public func setPreferredShutterStyle(_ style: ShutterStyle) {
        setPreferredShutterStyleQueue.sync {
            setPreferredShutterStyleCallsCount += 1
        setPreferredShutterStyleReceivedStyle = style
            setPreferredShutterStyleClosure?(style)
        }
    }

    //MARK: - setPreferredTemperature

    public var setPreferredTemperatureCallsCount = 0
    public var setPreferredTemperatureCalled: Bool {
        return setPreferredTemperatureCallsCount > 0
    }
    public var setPreferredTemperatureReceivedTemperature: TemperaturePreset?
    public var setPreferredTemperatureClosure: ((TemperaturePreset) -> Void)?
    public var setPreferredTemperatureQueue = DispatchQueue(label: "setPreferredTemperatureQueue")

    public func setPreferredTemperature(_ temperature: TemperaturePreset) {
        setPreferredTemperatureQueue.sync {
            setPreferredTemperatureCallsCount += 1
        setPreferredTemperatureReceivedTemperature = temperature
            setPreferredTemperatureClosure?(temperature)
        }
    }

    //MARK: - setShouldAddCapturesToApplicationPhotoAlbum

    public var setShouldAddCapturesToApplicationPhotoAlbumCallsCount = 0
    public var setShouldAddCapturesToApplicationPhotoAlbumCalled: Bool {
        return setShouldAddCapturesToApplicationPhotoAlbumCallsCount > 0
    }
    public var setShouldAddCapturesToApplicationPhotoAlbumReceivedBool: Bool?
    public var setShouldAddCapturesToApplicationPhotoAlbumClosure: ((Bool) -> Void)?
    public var setShouldAddCapturesToApplicationPhotoAlbumQueue = DispatchQueue(label: "setShouldAddCapturesToApplicationPhotoAlbumQueue")

    public func setShouldAddCapturesToApplicationPhotoAlbum(_ bool: Bool) {
        setShouldAddCapturesToApplicationPhotoAlbumQueue.sync {
            setShouldAddCapturesToApplicationPhotoAlbumCallsCount += 1
        setShouldAddCapturesToApplicationPhotoAlbumReceivedBool = bool
            setShouldAddCapturesToApplicationPhotoAlbumClosure?(bool)
        }
    }

    //MARK: - setShouldDoubleTapToFlipCamera

    public var setShouldDoubleTapToFlipCameraCallsCount = 0
    public var setShouldDoubleTapToFlipCameraCalled: Bool {
        return setShouldDoubleTapToFlipCameraCallsCount > 0
    }
    public var setShouldDoubleTapToFlipCameraReceivedBool: Bool?
    public var setShouldDoubleTapToFlipCameraClosure: ((Bool) -> Void)?
    public var setShouldDoubleTapToFlipCameraQueue = DispatchQueue(label: "setShouldDoubleTapToFlipCameraQueue")

    public func setShouldDoubleTapToFlipCamera(_ bool: Bool) {
        setShouldDoubleTapToFlipCameraQueue.sync {
            setShouldDoubleTapToFlipCameraCallsCount += 1
        setShouldDoubleTapToFlipCameraReceivedBool = bool
            setShouldDoubleTapToFlipCameraClosure?(bool)
        }
    }

    //MARK: - setShouldEmbedLocationDataInCaptures

    public var setShouldEmbedLocationDataInCapturesCallsCount = 0
    public var setShouldEmbedLocationDataInCapturesCalled: Bool {
        return setShouldEmbedLocationDataInCapturesCallsCount > 0
    }
    public var setShouldEmbedLocationDataInCapturesReceivedBool: Bool?
    public var setShouldEmbedLocationDataInCapturesClosure: ((Bool) -> Void)?
    public var setShouldEmbedLocationDataInCapturesQueue = DispatchQueue(label: "setShouldEmbedLocationDataInCapturesQueue")

    public func setShouldEmbedLocationDataInCaptures(_ bool: Bool) {
        setShouldEmbedLocationDataInCapturesQueue.sync {
            setShouldEmbedLocationDataInCapturesCallsCount += 1
        setShouldEmbedLocationDataInCapturesReceivedBool = bool
            setShouldEmbedLocationDataInCapturesClosure?(bool)
        }
    }

    //MARK: - setShouldEnableHaptics

    public var setShouldEnableHapticsCallsCount = 0
    public var setShouldEnableHapticsCalled: Bool {
        return setShouldEnableHapticsCallsCount > 0
    }
    public var setShouldEnableHapticsReceivedBool: Bool?
    public var setShouldEnableHapticsClosure: ((Bool) -> Void)?
    public var setShouldEnableHapticsQueue = DispatchQueue(label: "setShouldEnableHapticsQueue")

    public func setShouldEnableHaptics(_ bool: Bool) {
        setShouldEnableHapticsQueue.sync {
            setShouldEnableHapticsCallsCount += 1
        setShouldEnableHapticsReceivedBool = bool
            setShouldEnableHapticsClosure?(bool)
        }
    }

    //MARK: - setShouldEnableSoundEffects

    public var setShouldEnableSoundEffectsCallsCount = 0
    public var setShouldEnableSoundEffectsCalled: Bool {
        return setShouldEnableSoundEffectsCallsCount > 0
    }
    public var setShouldEnableSoundEffectsReceivedBool: Bool?
    public var setShouldEnableSoundEffectsClosure: ((Bool) -> Void)?
    public var setShouldEnableSoundEffectsQueue = DispatchQueue(label: "setShouldEnableSoundEffectsQueue")

    public func setShouldEnableSoundEffects(_ bool: Bool) {
        setShouldEnableSoundEffectsQueue.sync {
            setShouldEnableSoundEffectsCallsCount += 1
        setShouldEnableSoundEffectsReceivedBool = bool
            setShouldEnableSoundEffectsClosure?(bool)
        }
    }

    //MARK: - setshouldReverseCameraControls

    public var setshouldReverseCameraControlsCallsCount = 0
    public var setshouldReverseCameraControlsCalled: Bool {
        return setshouldReverseCameraControlsCallsCount > 0
    }
    public var setshouldReverseCameraControlsReceivedShouldReverse: Bool?
    public var setshouldReverseCameraControlsClosure: ((Bool) -> Void)?
    public var setshouldReverseCameraControlsQueue = DispatchQueue(label: "setshouldReverseCameraControlsQueue")

    public func setshouldReverseCameraControls(_ shouldReverse: Bool) {
        setshouldReverseCameraControlsQueue.sync {
            setshouldReverseCameraControlsCallsCount += 1
        setshouldReverseCameraControlsReceivedShouldReverse = shouldReverse
            setshouldReverseCameraControlsClosure?(shouldReverse)
        }
    }

    //MARK: - setShouldIncludeScreenshotsInGallery

    public var setShouldIncludeScreenshotsInGalleryCallsCount = 0
    public var setShouldIncludeScreenshotsInGalleryCalled: Bool {
        return setShouldIncludeScreenshotsInGalleryCallsCount > 0
    }
    public var setShouldIncludeScreenshotsInGalleryReceivedShouldInclude: Bool?
    public var setShouldIncludeScreenshotsInGalleryClosure: ((Bool) -> Void)?
    public var setShouldIncludeScreenshotsInGalleryQueue = DispatchQueue(label: "setShouldIncludeScreenshotsInGalleryQueue")

    public func setShouldIncludeScreenshotsInGallery(_ shouldInclude: Bool) {
        setShouldIncludeScreenshotsInGalleryQueue.sync {
            setShouldIncludeScreenshotsInGalleryCallsCount += 1
        setShouldIncludeScreenshotsInGalleryReceivedShouldInclude = shouldInclude
            setShouldIncludeScreenshotsInGalleryClosure?(shouldInclude)
        }
    }

    //MARK: - setlastKnownFrontFacingZoomValue

    public var setlastKnownFrontFacingZoomValueCallsCount = 0
    public var setlastKnownFrontFacingZoomValueCalled: Bool {
        return setlastKnownFrontFacingZoomValueCallsCount > 0
    }
    public var setlastKnownFrontFacingZoomValueReceivedNewValue: Float?
    public var setlastKnownFrontFacingZoomValueClosure: ((Float) -> Void)?
    public var setlastKnownFrontFacingZoomValueQueue = DispatchQueue(label: "setlastKnownFrontFacingZoomValueQueue")

    public func setlastKnownFrontFacingZoomValue(_ newValue: Float) {
        setlastKnownFrontFacingZoomValueQueue.sync {
            setlastKnownFrontFacingZoomValueCallsCount += 1
        setlastKnownFrontFacingZoomValueReceivedNewValue = newValue
            setlastKnownFrontFacingZoomValueClosure?(newValue)
        }
    }

    //MARK: - setlastKnownBackFacingZoomValue

    public var setlastKnownBackFacingZoomValueCallsCount = 0
    public var setlastKnownBackFacingZoomValueCalled: Bool {
        return setlastKnownBackFacingZoomValueCallsCount > 0
    }
    public var setlastKnownBackFacingZoomValueReceivedNewValue: Float?
    public var setlastKnownBackFacingZoomValueClosure: ((Float) -> Void)?
    public var setlastKnownBackFacingZoomValueQueue = DispatchQueue(label: "setlastKnownBackFacingZoomValueQueue")

    public func setlastKnownBackFacingZoomValue(_ newValue: Float) {
        setlastKnownBackFacingZoomValueQueue.sync {
            setlastKnownBackFacingZoomValueCallsCount += 1
        setlastKnownBackFacingZoomValueReceivedNewValue = newValue
            setlastKnownBackFacingZoomValueClosure?(newValue)
        }
    }

}
