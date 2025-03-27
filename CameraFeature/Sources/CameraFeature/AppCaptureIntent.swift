import AppIntents
import AVFoundation
import Foundation

public enum CameraPosition: String, Codable {
	case front
	case back
	
	var avFoundationPosition: AVCaptureDevice.Position {
		switch self {
		case .front:
			return .front
		case .back:
			return .back
		}
	}
}

@available(iOS 18, *)
public struct AppCaptureIntent: CameraCaptureIntent {
	public struct MyAppContext: Codable {
		var cameraPosition: CameraPosition = .back
	}
	
	public typealias AppContext = MyAppContext
	
	public static let title: LocalizedStringResource = "AppCaptureIntent"
	public static let description = IntentDescription("Capture photos with MyApp.")

	public init() { }
	
	@MainActor
	public func perform() async throws -> some IntentResult {
		return .result()
	}
}
