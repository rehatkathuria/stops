import AVFoundation
import CoreImage
import Foundation

public class SoftwareNameEnricher: NSObject, AVCapturePhotoFileDataRepresentationCustomizer {
	public func replacementMetadata(for photo: AVCapturePhoto) -> [String: Any]? {
		var metadata = photo.metadata
		if var tiffDictionary = metadata[kCGImagePropertyTIFFDictionary as String] as? [String: Any] {
			tiffDictionary[kCGImagePropertyTIFFSoftware as String] = "Stops"
			metadata[kCGImagePropertyTIFFDictionary as String] = tiffDictionary
		}
		return metadata
	}
}
