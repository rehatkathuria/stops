import AVFoundation
import Combine
import ComposableArchitecture
import Foundation
import Pipeline
import Preferences
import Shared
import UIKit

public protocol AVCaptureClient: AnyObject, AutoMockable {
	
	// MARK: - Properties (Publishers)
	
	var activeDevicePositionPublisher: AnyPublisher<AVCaptureDevice.Position, Never> { get }
	var captureLifecyclePublisher: AnyPublisher<CaptureLifecycle, Never> { get }
	var constituentDevicePublisher: AnyPublisher<ZoomLevelDisplayable?, Never> { get }
	
	var capturedImagePublisher: AnyPublisher<AVCapturedImage, Never> { get }
	var previewImagePublisher: AnyPublisher<AVPreviewImage, Never> { get }
	var redactedPreviewImagePublisher: AnyPublisher<AVPreviewImage, Never> { get }
	
	var statePublisher: AnyPublisher<SessionState, Never> { get }
	var qrCodesPublisher: AnyPublisher<AVMetadataMachineReadableCodeObject, Never> { get }

	// MARK: - Properties (State and Transformations)
	
	var aspectRatio: AspectRatio { get }
	var isAttemptingToRun: Bool { get }
	var isRunning: Bool { get }

	// MARK: - Power State
	
	func startCaptureSession(_ transformation: Transformation)
	func stopCaptureSession()

	// MARK: - Transformation
	
	func flushBuffer()

	func setAspectRatio(_ aspectRatio: AspectRatio)
	func setCameraPosition(_ position: AVCaptureDevice.Position)
	func setFocus(_ point: CGPoint)
	func toggleCamera()
	func toggleFlashMode() -> AVCaptureDevice.FlashMode

	func updateTransformation(_ transformation: Transformation)

	// MARK: - Photos
	
	func capture()
	
	// MARK: - Audio
	
	func setupMicrophoneIO()
	
	// MARK: -  Video
	
	func cancelRecordingVideo()
	func startRecordingVideo(
		url: URL
	) throws
	func stopRecordingVideo() async throws -> URL
	
	// MARK: - QR Codes
	
	func startTrackingQRCodes()
	func stopTrackingQRCodes()
	
	// MARK: - Zoom
	
	var availableZoomFactors: [NSNumber] { get}
	
	func rampToNext(_ direction: ZoomDirection) -> Bool
	
	func resetZoomFactor()
	func updateZoomFactor(low: CGFloat, high: CGFloat)
}

private enum AVCaptureClientKey: DependencyKey {
	static let liveValue: AVCaptureClient = LiveAVCaptureClient(
		context: {
			if let device = MTLCreateSystemDefaultDevice() {
				return CIContext(mtlDevice: device)
			} else {
				return CIContext()
			}
		}(),
		preferences: PreferencesClientKey.liveValue
	)
	static var testValue: AVCaptureClient = AVCaptureClientMock(override: true)
}

public extension DependencyValues {
	var avCaptureClient: AVCaptureClient {
		get { self[AVCaptureClientKey.self] }
		set { self[AVCaptureClientKey.self] = newValue }
	}
}
