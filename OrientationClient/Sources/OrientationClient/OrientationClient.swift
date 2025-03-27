import Foundation
import Combine
import CoreMotion
import AVFoundation
import UIKit

public final class OrientationClient {

	public var deviceOrientationPublisher: AnyPublisher<UIDeviceOrientation, Never> {
		deviceOrientationSubject.eraseToAnyPublisher()
	}
	
	public static let shared = OrientationClient()
	
	private let motionManager = CMMotionManager()
	private let queue = OperationQueue()
	private var deviceOrientation: UIDeviceOrientation = .unknown
	private let deviceOrientationSubject = PassthroughSubject<UIDeviceOrientation, Never>()
	
	public init() {
		motionManager.accelerometerUpdateInterval = 1.0 / 60
		motionManager.deviceMotionUpdateInterval = 1.0 / 60
		motionManager.gyroUpdateInterval = 1.0 / 60
		motionManager.magnetometerUpdateInterval = 1.0 / 60
	}
	
	public func startMeasuring() {
		guard
			motionManager.isDeviceMotionAvailable
		else {
			return
		}
		
		motionManager.startAccelerometerUpdates(to: queue) { [weak self] (accelerometerData, error) in
			guard let self, let accelerometerData else { return }
			
			let acceleration = accelerometerData.acceleration
			let xx = -acceleration.x
			let yy = acceleration.y
			let z = acceleration.z
			let angle = atan2(yy, xx)
			var deviceOrientation = self.deviceOrientation
			let absoluteZ = fabs(z)
			
			if deviceOrientation == .faceUp || deviceOrientation == .faceDown {
				if absoluteZ < 0.845 {
					if angle < -2.6 {
						deviceOrientation = .landscapeRight
					} else if angle > -2.05 && angle < -1.1 {
						deviceOrientation = .portrait
					} else if angle > -0.48 && angle < 0.48 {
						deviceOrientation = .landscapeLeft
					} else if angle > 1.08 && angle < 2.08 {
						deviceOrientation = .portraitUpsideDown
					}
				} else if z < 0 {
					deviceOrientation = .faceUp
				} else if z > 0 {
					deviceOrientation = .faceDown
				}
			} else {
				if z > 0.875 {
					deviceOrientation = .faceDown
				} else if z < -0.875 {
					deviceOrientation = .faceUp
				} else {
					switch deviceOrientation {
					case .landscapeLeft:
						if angle < -1.07 {
							deviceOrientation = .portrait
						}
						if angle > 1.08 {
							deviceOrientation = .portraitUpsideDown
						}
					case .landscapeRight:
						if angle < 0 && angle > -2.05 {
							deviceOrientation = .portrait
						}
						if angle > 0 && angle < 2.05 {
							deviceOrientation = .portraitUpsideDown
						}
					case .portraitUpsideDown:
						if angle > 2.66 {
							deviceOrientation = .landscapeRight
						}
						if angle < 0.48 {
							deviceOrientation = .landscapeLeft
						}
					case .portrait:
						if angle > -0.47 {
							deviceOrientation = .landscapeLeft
						}
						if angle < -2.64 {
							deviceOrientation = .landscapeRight
						}
					default:
						if angle > -0.47 {
							deviceOrientation = .landscapeLeft
						}
						if angle < -2.64 {
							deviceOrientation = .landscapeRight
						}
					}
				}
			}
			if self.deviceOrientation != deviceOrientation {
				self.deviceOrientation = deviceOrientation
				self.deviceOrientationSubject.send(deviceOrientation)
			}
		}
	}
	
	func stopMeasuring() {
		motionManager.stopAccelerometerUpdates()
	}
	
	func currentInterfaceOrientation() -> AVCaptureVideoOrientation {
		switch deviceOrientation {
		case .portrait:
			return .portrait
		case .landscapeRight:
			return .landscapeLeft
		case .landscapeLeft:
			return .landscapeRight
		case .portraitUpsideDown:
			return .portraitUpsideDown
		default:
			return .portrait
		}
	}
}
