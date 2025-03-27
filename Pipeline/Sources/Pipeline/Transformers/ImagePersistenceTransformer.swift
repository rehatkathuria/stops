import Accelerate
import AVFoundation
import CoreImage
import Foundation
import UIKit

public struct PersistenceTransformer {
	
	// MARK: - Properties
	
	public static func uiimage(
		cgimg: CGImage,
		orientation: UIDeviceOrientation,
		position: AVCaptureDevice.Position
	) -> UIImage? {
		let rotation: Int? = {
			switch orientation {
			case .landscapeLeft: return position == .front ? kRotate270DegreesCounterClockwise : kRotate270DegreesClockwise
			case .landscapeRight: return position == .front ? kRotate90DegreesCounterClockwise : kRotate90DegreesClockwise
			case .portraitUpsideDown: return kRotate180DegreesClockwise
			default: return nil
			}
		}()
		
		guard
				let buffer = try? vImage_Buffer(cgImage: cgimg),
				let format = vImage_CGImageFormat(cgImage: cgimg)
		else { return nil }

		var destination: vImage_Buffer
		
		if let rotation, let rotated = PersistenceTransformer.rotateNinety(source: buffer, rotation: rotation) {
			destination = rotated
		}
		else {
			destination = buffer
		}

		if position == .front {
			var flippedBuffer: vImage_Buffer
			
			flippedBuffer = try! vImage_Buffer(
				width: .init(destination.width),
				height: .init(destination.height),
				bitsPerPixel: format.bitsPerPixel
			)
			horizontalReflectBuffer(source: destination, destination: &flippedBuffer)

			guard
				let returnable = try? flippedBuffer.createCGImage(
					format: format,
					flags: [.highQualityResampling]
				)
			else { return nil }
			
			defer {
				flippedBuffer.free()
				destination.free()
			}

			return .init(cgImage: returnable)
		}
		else {
			guard
				let returnable = try? destination.createCGImage(
					format: format,
					flags: [.highQualityResampling]
				)
			else { return nil }
			
			defer { destination.free() }
			
			return .init(cgImage: returnable)
		}
	}
	
	static func rotateNinety(
		source: vImage_Buffer,
		rotation: Int
	) -> vImage_Buffer? {
		guard
			var destination: vImage_Buffer = {
				switch rotation {
				case kRotate0DegreesClockwise, kRotate180DegreesClockwise:
					return try? vImage_Buffer(
						size: source.size,
						bitsPerPixel: 8 * 4
					)
				case kRotate90DegreesClockwise, kRotate270DegreesClockwise, kRotate90DegreesCounterClockwise, kRotate270DegreesCounterClockwise:
					return try? vImage_Buffer(
						width: Int(source.size.height),
						height: Int(source.size.width),
						bitsPerPixel: 8 * 4
					)
				default: return nil
				}
			}()
		else { return nil }
		
		_ = withUnsafePointer(to: source) { sourcePointer in
			vImageRotate90_ARGB8888(
				sourcePointer,
				&destination,
				UInt8(rotation),
				[0],
				vImage_Flags(kvImageNoFlags)
			)
		}
		
		return destination
	}
	
	static func horizontalReflectBuffer(
		source: vImage_Buffer,
		destination: inout vImage_Buffer
	) {
		precondition(
			source.size == destination.size,
			"Source and destination buffers must have the same size."
		)
		
		_ = withUnsafePointer(to: source) { srcPointer in
			vImageHorizontalReflect_ARGB8888(
				srcPointer,
				&destination,
				vImage_Flags(kvImageNoFlags)
			)
		}
	}

}
