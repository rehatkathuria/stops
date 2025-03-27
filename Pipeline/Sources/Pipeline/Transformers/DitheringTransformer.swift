import Accelerate
import AVFoundation
import CoreImage
import Foundation
import Shared

var format = vImage_CGImageFormat(
	bitsPerComponent: 32,
	bitsPerPixel: 32,
	colorSpace: CGColorSpaceCreateDeviceRGB(),
	bitmapInfo: .alphaInfoMask
)!

public final class DitheringTransformer {
	
	// MARK: - Properties
	
	public private(set) var outputImage: CGImage?
	
	// MARK: - Lifecycle
	
	public init(
		image: CIImage,
		context: CIContext
	) throws {
		guard
			let sourceCGImage = context.createCGImage(
				image,
				from: .init(
					origin: .zero,
					size: .init(
						width: image.extent.size.width,
						height: image.extent.size.height
					)
				)
			),
			var sourceBuffer = try? vImage_Buffer(
				cgImage: sourceCGImage
			)
		else { throw PipelineError.failedToConvert }
		
		var error = kvImageNoError
		
		var ditheredLuma = try vImage_Buffer(
			width: Int(sourceBuffer.width),
			height: Int(sourceBuffer.height),
			bitsPerPixel: 32
		)
		
		vImageBuffer_Init(
			&ditheredLuma,
			sourceBuffer.height,
			sourceBuffer.width,
			32,
			vImage_Flags(kvImageNoFlags)
		)

		vImageConvert_Planar8toPlanar1(
			&sourceBuffer,
			&ditheredLuma,
			nil,
			Int32(kvImageConvert_DitherFloydSteinberg),
			vImage_Flags(kvImageNoFlags)
		)

		vImageConvert_Planar1toPlanar8(
			&ditheredLuma,
			&sourceBuffer,
			vImage_Flags(kvImageNoFlags)
		)
		
		let img = vImageCreateCGImageFromBuffer(
			&sourceBuffer,
			&format,
			nil,
			nil,
			vImage_Flags(kvImageNoFlags),
			&error
		)
		
		outputImage = img?.takeRetainedValue()
		
		ditheredLuma.free()
		sourceBuffer.free()
	}
	
	deinit { outputImage = nil }
}
