import Photos
#if canImport(UIKit)
import UIKit

struct UnexpectedNilError: Error { }

public extension PHImageManager {
	func requestImage(
		for asset: PHAsset,
		targetSize: CGSize,
		contentMode: PHImageContentMode,
		options: PHImageRequestOptions?
	) async throws -> UIImage {
		options?.isSynchronous = false
		
		var requestID: PHImageRequestID?
		
		return try await withTaskCancellationHandler(
			handler: { [requestID] in
				guard let requestID = requestID else {
					return
				}
				
				cancelImageRequest(requestID)
			}
		) {
			try await withCheckedThrowingContinuation { continuation in
				requestID = requestImage(
					for: asset,
					targetSize: targetSize,
					contentMode: contentMode,
					options: options
				) { image, info in
					if let error = info?[PHImageErrorKey] as? Error {
						continuation.resume(throwing: error)
						return
					}
					
					guard !(info?[PHImageCancelledKey] as? Bool ?? false) else {
						continuation.resume(throwing: CancellationError())
						return
					}
					
					// When degraded image is provided, the completion handler will be called again.
					guard !(info?[PHImageResultIsDegradedKey] as? Bool ?? false) else {
						return
					}
					
					guard let image = image else {
						// This should in theory not happen.
						continuation.resume(throwing: UnexpectedNilError())
						return
					}
					
					// According to the docs, the image is guaranteed at this point.
					continuation.resume(returning: image)
				}
			}
		}
	}
}
#endif
