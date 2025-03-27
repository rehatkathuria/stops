import AVFoundation
import CoreImage
import Foundation
import MobileCoreServices
import Shared
import UIKit

public struct MetadataEnricher {
	public static func enrich(
		_ imgData: Data,
		_ metadata: [String: Any],
		_ orientation: UIDeviceOrientation,
		_ position: AVCaptureDevice.Position,
		_ stopsEXIF: StopsEXIF
	) -> Data? {
		let data = NSMutableData()
		
		guard
			let source = CGImageSourceCreateWithData(
				imgData as CFData,
				([kCGImageSourceCreateThumbnailWithTransform: true] as CFDictionary)
			),
			let destination = CGImageDestinationCreateWithData(data as CFMutableData, kUTTypeJPEG, 1, nil)
		else { return imgData }
		
		var metadata = metadata
		metadata["Orientation"] = orientation.exifOrientation(position).rawValue as CFNumber
		
		if var tiffDictionary = metadata[kCGImagePropertyTIFFDictionary as String] as? [String: Any] {
			tiffDictionary[kCGImagePropertyTIFFSoftware as String] = "Stops"
			metadata[kCGImagePropertyTIFFDictionary as String] = tiffDictionary
		}
		
		CGImageDestinationAddImageFromSource(destination, source, 0, (metadata as CFDictionary))
		CGImageDestinationFinalize(destination)
		
		return data as Data
	}
}

extension UIDeviceOrientation {
	func exifOrientation(_ position: AVCaptureDevice.Position) -> CGImagePropertyOrientation {
		switch self {
		case .faceUp, .faceDown, .portrait: return position == .front ? .upMirrored : .up
		case .landscapeLeft: return position == .front ? .leftMirrored : .left
		case .landscapeRight: return position == .front ? .rightMirrored : .right
		case .portraitUpsideDown: return position == .front ? .downMirrored : .down
		case .unknown: return .up
		@unknown default: return .up
		}
	}
}
