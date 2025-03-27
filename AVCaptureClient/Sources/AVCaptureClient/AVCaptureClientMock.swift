import Combine
import Foundation

extension AVCaptureClientMock {
	public convenience init(override: Bool) {
		self.init()
		self.underlyingPreviewImagePublisher = CurrentValueSubject(AVPreviewImage(rawValue: .init())).eraseToAnyPublisher()
		self.underlyingRedactedPreviewImagePublisher = CurrentValueSubject(AVPreviewImage(rawValue: .init())).eraseToAnyPublisher()
		self.underlyingIsRunning = false
		self.underlyingIsAttemptingToRun = false
		self.underlyingCaptureLifecyclePublisher = CurrentValueSubject(.idle).eraseToAnyPublisher()
		self.underlyingCapturedImagePublisher = CurrentValueSubject(
			.init(identifier: 0, pixelWidth: 100, pixelHeight: 100, position: .front, rawValue: .init())
		).eraseToAnyPublisher()
	}
}
