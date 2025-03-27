import AVFoundation.AVCaptureDevice
import Foundation
import Pipeline
import UIKit

public enum CaptureLifecycle: Equatable {
	case didCapture(Int64)
	case idle
	case willBeginCapture(Int64)
	case willCapture(Int64)
	case willBeginRecording
	case recording(Measurement<UnitDuration>)
}

public struct AVCapturedImage: Equatable {
	public let identifier: Int64
	public let pixelWidth: Int
	public let pixelHeight: Int
	public let position: AVCaptureDevice.Position
	public let rawValue: Data
}

public struct AVPreviewImage: Equatable {
	public let rawValue: UIImage?
}

public enum SessionError: Equatable, Error {
	case invalidCaptureInput
	case invalidCaptureOutput
	case missingVideoDevice
	case missingAudioDevice
	case unableToAddDataConnection
	case pipeline(PipelineError)
	case invalidRecordingState
}

public enum SessionState: Equatable {
	case idle
	case success
	case running
	case notAuthorized
	case error(NSError, Bool)
	case unavailable
}

public enum CaptureError: Error {
	case failedToGenerateSettingsForAssetWriter
}

public enum ZoomDirection {
	case tighter
	case wider
}

public enum ZoomLevelDisplayable: Equatable {
	case string(String)
	case image(UIImage)
}
