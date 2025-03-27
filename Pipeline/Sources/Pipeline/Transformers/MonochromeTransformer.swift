import Accelerate
import Combine
import CoreImage
import ExtensionKit
import UIKit

let monochromeFormat = vImage_CGImageFormat(
	bitsPerComponent: 8,
	bitsPerPixel: 8,
	colorSpace: CGColorSpaceCreateDeviceGray(),
	bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
)!

public final class MonochromeTransformer {
	public private(set) var outputImage: CGImage?
	
	/***
	 The coefficients below have been fine-tuned for aesthetic preference. The ones outlined by Apple indicating human preference are as follows: let redCoefficient: Float = 0.2126, let greenCoefficient: Float = 0.7152 and let blueCoefficient: Float = 0.0722. The amendments we have made allow for a slightly punchier look with brighter highlights and darker shadows. This, in conjunction with the other steps of the pipeline flow ensure a look unique to Eff.
	 ***/
	public init(
		image: CIImage,
		context: CIContext,
		redCoefficient: Float = 0.2127,
		greenCoefficient: Float = 0.8014,
		blueCoefficient: Float = 0.0722
	) throws {
		guard
			let image = context.createCGImage(
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
				cgImage: image
			),
			var destinationBuffer = try? vImage_Buffer(
				width: Int(sourceBuffer.width),
				height: Int(sourceBuffer.height),
				bitsPerPixel: 8
			)
		else { throw PipelineError.failedToConvert }
		
		let divisor: Int32 = 0x1000
		let fDivisor = Float(divisor)
		
		var coefficientsMatrix = [
			Int16(redCoefficient * fDivisor),
			Int16(greenCoefficient * fDivisor),
			Int16(blueCoefficient * fDivisor),
			0
		]
		
		let preBias: [Int16] = [0, 0, 0, 0]
		let postBias: Int32 = 0
		
		vImageMatrixMultiply_ARGB8888ToPlanar8(
			&sourceBuffer,
			&destinationBuffer,
			&coefficientsMatrix,
			divisor,
			preBias,
			postBias,
			vImage_Flags(kvImageNoFlags)
		)
		
		outputImage = try? destinationBuffer.createCGImage(format: monochromeFormat)
		
		sourceBuffer.free()
		destinationBuffer.free()
	}
}
