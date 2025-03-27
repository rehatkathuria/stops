// Generated using Sourcery 1.8.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Shared

import Pipeline

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

public final class AVCaptureClientMock: AVCaptureClient, @unchecked Sendable {
    public init() {}
    public var activeDevicePositionPublisher: AnyPublisher<AVCaptureDevice.Position, Never> {
        get { return underlyingActiveDevicePositionPublisher }
        set(value) { underlyingActiveDevicePositionPublisher = value }
    }
    public var underlyingActiveDevicePositionPublisher: AnyPublisher<AVCaptureDevice.Position, Never>!
    public var captureLifecyclePublisher: AnyPublisher<CaptureLifecycle, Never> {
        get { return underlyingCaptureLifecyclePublisher }
        set(value) { underlyingCaptureLifecyclePublisher = value }
    }
    public var underlyingCaptureLifecyclePublisher: AnyPublisher<CaptureLifecycle, Never>!
    public var constituentDevicePublisher: AnyPublisher<ZoomLevelDisplayable?, Never> {
        get { return underlyingConstituentDevicePublisher }
        set(value) { underlyingConstituentDevicePublisher = value }
    }
    public var underlyingConstituentDevicePublisher: AnyPublisher<ZoomLevelDisplayable?, Never>!
    public var capturedImagePublisher: AnyPublisher<AVCapturedImage, Never> {
        get { return underlyingCapturedImagePublisher }
        set(value) { underlyingCapturedImagePublisher = value }
    }
    public var underlyingCapturedImagePublisher: AnyPublisher<AVCapturedImage, Never>!
    public var previewImagePublisher: AnyPublisher<AVPreviewImage, Never> {
        get { return underlyingPreviewImagePublisher }
        set(value) { underlyingPreviewImagePublisher = value }
    }
    public var underlyingPreviewImagePublisher: AnyPublisher<AVPreviewImage, Never>!
    public var redactedPreviewImagePublisher: AnyPublisher<AVPreviewImage, Never> {
        get { return underlyingRedactedPreviewImagePublisher }
        set(value) { underlyingRedactedPreviewImagePublisher = value }
    }
    public var underlyingRedactedPreviewImagePublisher: AnyPublisher<AVPreviewImage, Never>!
    public var statePublisher: AnyPublisher<SessionState, Never> {
        get { return underlyingStatePublisher }
        set(value) { underlyingStatePublisher = value }
    }
    public var underlyingStatePublisher: AnyPublisher<SessionState, Never>!
    public var qrCodesPublisher: AnyPublisher<AVMetadataMachineReadableCodeObject, Never> {
        get { return underlyingQrCodesPublisher }
        set(value) { underlyingQrCodesPublisher = value }
    }
    public var underlyingQrCodesPublisher: AnyPublisher<AVMetadataMachineReadableCodeObject, Never>!
    public var aspectRatio: AspectRatio {
        get { return underlyingAspectRatio }
        set(value) { underlyingAspectRatio = value }
    }
    public var underlyingAspectRatio: AspectRatio!
    public var isAttemptingToRun: Bool {
        get { return underlyingIsAttemptingToRun }
        set(value) { underlyingIsAttemptingToRun = value }
    }
    public var underlyingIsAttemptingToRun: Bool!
    public var isRunning: Bool {
        get { return underlyingIsRunning }
        set(value) { underlyingIsRunning = value }
    }
    public var underlyingIsRunning: Bool!
    public var availableZoomFactors: [NSNumber] = []

    //MARK: - startCaptureSession

    public var startCaptureSessionCallsCount = 0
    public var startCaptureSessionCalled: Bool {
        return startCaptureSessionCallsCount > 0
    }
    public var startCaptureSessionReceivedTransformation: Transformation?
    public var startCaptureSessionClosure: ((Transformation) -> Void)?
    public var startCaptureSessionQueue = DispatchQueue(label: "startCaptureSessionQueue")

    public func startCaptureSession(_ transformation: Transformation) {
        startCaptureSessionQueue.sync {
            startCaptureSessionCallsCount += 1
        startCaptureSessionReceivedTransformation = transformation
            startCaptureSessionClosure?(transformation)
        }
    }

    //MARK: - stopCaptureSession

    public var stopCaptureSessionCallsCount = 0
    public var stopCaptureSessionCalled: Bool {
        return stopCaptureSessionCallsCount > 0
    }
    public var stopCaptureSessionClosure: (() -> Void)?
    public var stopCaptureSessionQueue = DispatchQueue(label: "stopCaptureSessionQueue")

    public func stopCaptureSession() {
        stopCaptureSessionQueue.sync {
            stopCaptureSessionCallsCount += 1
            stopCaptureSessionClosure?()
        }
    }

    //MARK: - flushBuffer

    public var flushBufferCallsCount = 0
    public var flushBufferCalled: Bool {
        return flushBufferCallsCount > 0
    }
    public var flushBufferClosure: (() -> Void)?
    public var flushBufferQueue = DispatchQueue(label: "flushBufferQueue")

    public func flushBuffer() {
        flushBufferQueue.sync {
            flushBufferCallsCount += 1
            flushBufferClosure?()
        }
    }

    //MARK: - setAspectRatio

    public var setAspectRatioCallsCount = 0
    public var setAspectRatioCalled: Bool {
        return setAspectRatioCallsCount > 0
    }
    public var setAspectRatioReceivedAspectRatio: AspectRatio?
    public var setAspectRatioClosure: ((AspectRatio) -> Void)?
    public var setAspectRatioQueue = DispatchQueue(label: "setAspectRatioQueue")

    public func setAspectRatio(_ aspectRatio: AspectRatio) {
        setAspectRatioQueue.sync {
            setAspectRatioCallsCount += 1
        setAspectRatioReceivedAspectRatio = aspectRatio
            setAspectRatioClosure?(aspectRatio)
        }
    }

    //MARK: - setCameraPosition

    public var setCameraPositionCallsCount = 0
    public var setCameraPositionCalled: Bool {
        return setCameraPositionCallsCount > 0
    }
    public var setCameraPositionReceivedPosition: AVCaptureDevice.Position?
    public var setCameraPositionClosure: ((AVCaptureDevice.Position) -> Void)?
    public var setCameraPositionQueue = DispatchQueue(label: "setCameraPositionQueue")

    public func setCameraPosition(_ position: AVCaptureDevice.Position) {
        setCameraPositionQueue.sync {
            setCameraPositionCallsCount += 1
        setCameraPositionReceivedPosition = position
            setCameraPositionClosure?(position)
        }
    }

    //MARK: - setFocus

    public var setFocusCallsCount = 0
    public var setFocusCalled: Bool {
        return setFocusCallsCount > 0
    }
    public var setFocusReceivedPoint: CGPoint?
    public var setFocusClosure: ((CGPoint) -> Void)?
    public var setFocusQueue = DispatchQueue(label: "setFocusQueue")

    public func setFocus(_ point: CGPoint) {
        setFocusQueue.sync {
            setFocusCallsCount += 1
        setFocusReceivedPoint = point
            setFocusClosure?(point)
        }
    }

    //MARK: - toggleCamera

    public var toggleCameraCallsCount = 0
    public var toggleCameraCalled: Bool {
        return toggleCameraCallsCount > 0
    }
    public var toggleCameraClosure: (() -> Void)?
    public var toggleCameraQueue = DispatchQueue(label: "toggleCameraQueue")

    public func toggleCamera() {
        toggleCameraQueue.sync {
            toggleCameraCallsCount += 1
            toggleCameraClosure?()
        }
    }

    //MARK: - toggleFlashMode

    public var toggleFlashModeCallsCount = 0
    public var toggleFlashModeCalled: Bool {
        return toggleFlashModeCallsCount > 0
    }
    public var toggleFlashModeReturnValue: AVCaptureDevice.FlashMode!
    public var toggleFlashModeClosure: (() -> AVCaptureDevice.FlashMode)?
    public var toggleFlashModeQueue = DispatchQueue(label: "toggleFlashModeQueue")

    public func toggleFlashMode() -> AVCaptureDevice.FlashMode {
        toggleFlashModeQueue.sync {
            toggleFlashModeCallsCount += 1
            return toggleFlashModeClosure.map({ $0() }) ?? toggleFlashModeReturnValue
        }
    }

    //MARK: - updateTransformation

    public var updateTransformationCallsCount = 0
    public var updateTransformationCalled: Bool {
        return updateTransformationCallsCount > 0
    }
    public var updateTransformationReceivedTransformation: Transformation?
    public var updateTransformationClosure: ((Transformation) -> Void)?
    public var updateTransformationQueue = DispatchQueue(label: "updateTransformationQueue")

    public func updateTransformation(_ transformation: Transformation) {
        updateTransformationQueue.sync {
            updateTransformationCallsCount += 1
        updateTransformationReceivedTransformation = transformation
            updateTransformationClosure?(transformation)
        }
    }

    //MARK: - capture

    public var captureCallsCount = 0
    public var captureCalled: Bool {
        return captureCallsCount > 0
    }
    public var captureClosure: (() -> Void)?
    public var captureQueue = DispatchQueue(label: "captureQueue")

    public func capture() {
        captureQueue.sync {
            captureCallsCount += 1
            captureClosure?()
        }
    }

    //MARK: - setupMicrophoneIO

    public var setupMicrophoneIOCallsCount = 0
    public var setupMicrophoneIOCalled: Bool {
        return setupMicrophoneIOCallsCount > 0
    }
    public var setupMicrophoneIOClosure: (() -> Void)?
    public var setupMicrophoneIOQueue = DispatchQueue(label: "setupMicrophoneIOQueue")

    public func setupMicrophoneIO() {
        setupMicrophoneIOQueue.sync {
            setupMicrophoneIOCallsCount += 1
            setupMicrophoneIOClosure?()
        }
    }

    //MARK: - cancelRecordingVideo

    public var cancelRecordingVideoCallsCount = 0
    public var cancelRecordingVideoCalled: Bool {
        return cancelRecordingVideoCallsCount > 0
    }
    public var cancelRecordingVideoClosure: (() -> Void)?
    public var cancelRecordingVideoQueue = DispatchQueue(label: "cancelRecordingVideoQueue")

    public func cancelRecordingVideo() {
        cancelRecordingVideoQueue.sync {
            cancelRecordingVideoCallsCount += 1
            cancelRecordingVideoClosure?()
        }
    }

    //MARK: - startRecordingVideo

    public var startRecordingVideoUrlThrowableError: Error?
    public var startRecordingVideoUrlCallsCount = 0
    public var startRecordingVideoUrlCalled: Bool {
        return startRecordingVideoUrlCallsCount > 0
    }
    public var startRecordingVideoUrlReceivedUrl: URL?
    public var startRecordingVideoUrlClosure: ((URL) throws -> Void)?
    public var startRecordingVideoUrlQueue = DispatchQueue(label: "startRecordingVideoUrlQueue")

    public func startRecordingVideo(url: URL) throws {
        try startRecordingVideoUrlQueue.sync {
            startRecordingVideoUrlCallsCount += 1
        startRecordingVideoUrlReceivedUrl = url
        if let error = startRecordingVideoUrlThrowableError {
            throw error
        }
            try startRecordingVideoUrlClosure?(url)
        }
    }

    //MARK: - stopRecordingVideo

    public var stopRecordingVideoThrowableError: Error?
    public var stopRecordingVideoCallsCount = 0
    public var stopRecordingVideoCalled: Bool {
        return stopRecordingVideoCallsCount > 0
    }
    public var stopRecordingVideoReturnValue: URL!
    public var stopRecordingVideoClosure: (() throws -> URL)?
    public var stopRecordingVideoQueue = DispatchQueue(label: "stopRecordingVideoQueue")

    public func stopRecordingVideo() throws -> URL {
        try stopRecordingVideoQueue.sync {
            stopRecordingVideoCallsCount += 1
        if let error = stopRecordingVideoThrowableError {
            throw error
        }
            return try stopRecordingVideoClosure.map({ try $0() }) ?? stopRecordingVideoReturnValue
        }
    }

    //MARK: - startTrackingQRCodes

    public var startTrackingQRCodesCallsCount = 0
    public var startTrackingQRCodesCalled: Bool {
        return startTrackingQRCodesCallsCount > 0
    }
    public var startTrackingQRCodesClosure: (() -> Void)?
    public var startTrackingQRCodesQueue = DispatchQueue(label: "startTrackingQRCodesQueue")

    public func startTrackingQRCodes() {
        startTrackingQRCodesQueue.sync {
            startTrackingQRCodesCallsCount += 1
            startTrackingQRCodesClosure?()
        }
    }

    //MARK: - stopTrackingQRCodes

    public var stopTrackingQRCodesCallsCount = 0
    public var stopTrackingQRCodesCalled: Bool {
        return stopTrackingQRCodesCallsCount > 0
    }
    public var stopTrackingQRCodesClosure: (() -> Void)?
    public var stopTrackingQRCodesQueue = DispatchQueue(label: "stopTrackingQRCodesQueue")

    public func stopTrackingQRCodes() {
        stopTrackingQRCodesQueue.sync {
            stopTrackingQRCodesCallsCount += 1
            stopTrackingQRCodesClosure?()
        }
    }

    //MARK: - rampToNext

    public var rampToNextCallsCount = 0
    public var rampToNextCalled: Bool {
        return rampToNextCallsCount > 0
    }
    public var rampToNextReceivedDirection: ZoomDirection?
    public var rampToNextReturnValue: Bool!
    public var rampToNextClosure: ((ZoomDirection) -> Bool)?
    public var rampToNextQueue = DispatchQueue(label: "rampToNextQueue")

    public func rampToNext(_ direction: ZoomDirection) -> Bool {
        rampToNextQueue.sync {
            rampToNextCallsCount += 1
        rampToNextReceivedDirection = direction
            return rampToNextClosure.map({ $0(direction) }) ?? rampToNextReturnValue
        }
    }

    //MARK: - resetZoomFactor

    public var resetZoomFactorCallsCount = 0
    public var resetZoomFactorCalled: Bool {
        return resetZoomFactorCallsCount > 0
    }
    public var resetZoomFactorClosure: (() -> Void)?
    public var resetZoomFactorQueue = DispatchQueue(label: "resetZoomFactorQueue")

    public func resetZoomFactor() {
        resetZoomFactorQueue.sync {
            resetZoomFactorCallsCount += 1
            resetZoomFactorClosure?()
        }
    }

    //MARK: - updateZoomFactor

    public var updateZoomFactorLowHighCallsCount = 0
    public var updateZoomFactorLowHighCalled: Bool {
        return updateZoomFactorLowHighCallsCount > 0
    }
    public var updateZoomFactorLowHighReceivedArguments: (low: CGFloat, high: CGFloat)?
    public var updateZoomFactorLowHighClosure: ((CGFloat, CGFloat) -> Void)?
    public var updateZoomFactorLowHighQueue = DispatchQueue(label: "updateZoomFactorLowHighQueue")

    public func updateZoomFactor(low: CGFloat, high: CGFloat) {
        updateZoomFactorLowHighQueue.sync {
            updateZoomFactorLowHighCallsCount += 1
            updateZoomFactorLowHighReceivedArguments = (low: low, high: high)
            updateZoomFactorLowHighClosure?(low, high)
        }
    }

}
