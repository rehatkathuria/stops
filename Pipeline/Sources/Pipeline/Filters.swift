import CoreImage
import Shared
import UIKit.UIImage

public let brighten: (CIImage) -> (CIImage) = { image in
	guard
		let brighten = CIFilter(name: "CIExposureAdjust")
	else { return image }
	
	brighten.setValue(image, forKey: kCIInputImageKey)
	brighten.setValue(0.5, forKey: kCIInputEVKey)
	
	return brighten.outputImage ?? image
}

public let cool: (CIImage) -> (CIImage) = { image in
	guard
		let temperature = CIFilter(name: "CITemperatureAndTint")
	else {
		return image
	}
	
	temperature.setValue(image, forKey: kCIInputImageKey)
	temperature.setValue(CIVector(x: -1400 + 6500, y: 0), forKey: "inputNeutral")
	temperature.setValue(CIVector(x: 6500, y: 0), forKey: "inputTargetNeutral")
	
	return temperature.outputImage ?? image
}

public let redact: (CIImage, CIContext) -> (UIImage?, Data?) = { (image, context) in
	guard
		let blur = CIFilter(name: "CIGaussianBlur"),
		let affine = CIFilter(name: "CIAffineClamp")
	else {
		return (nil, nil)
	}

	affine.setDefaults()
	affine.setValue(image, forKey: kCIInputImageKey)
	let clamp = affine.value(forKey: kCIOutputImageKey)
	
	blur.setDefaults()
	blur.setValue(clamp, forKey: kCIInputImageKey)
	blur.setValue(90, forKey: kCIInputRadiusKey)
	
	let output = blur.outputImage ?? image
	
	guard
		let cgimg = context.createCGImage(output, from: image.extent)
	else { return (nil, nil) }
		
	let uiimg = UIImage(cgImage: cgimg)
	
	guard
		let data = uiimg.jpegData(compressionQuality: 1.0)
	else { return (nil, nil) }
	
	return (uiimg, data)
}

public let regulate: (CIImage) -> (CIImage) = { image in
	guard
		let temperature = CIFilter(name: "CITemperatureAndTint")
	else {
		return image
	}
	
	#warning("Revisit the vectors below")
	temperature.setValue(image, forKey: kCIInputImageKey)
	temperature.setValue(CIVector(x: 6500, y: 0), forKey: "inputNeutral")
	temperature.setValue(CIVector(x: 9500, y: 0), forKey: "inputTargetNeutral")
	
	return temperature.outputImage ?? image
}

public let colour: (CIImage) -> (CIImage) = { image in
	guard
		let saturation = CIFilter(name: "CIColorControls")
	else { return image }
	
	saturation.setValue(image, forKey: kCIInputImageKey)
	saturation.setValue(1.05, forKey: kCIInputSaturationKey)
	
	return saturation.outputImage ?? image
}

public let noise: (CIImage, GrainPresence) -> (CIImage) = { image, presence in
	guard
		presence != .none,
		let blend = CIFilter(name: "CIMultiplyBlendMode"),
		let bw = CIFilter(name: "CIColorMonochrome"),
		let invert = CIFilter(name: "CIColorInvert"),
		let overlay = CIFilter(name: "CIColorMatrix"),
		let unsharp = CIFilter(name: "CIUnsharpMask"),
		let random = CIFilter(name: "CIRandomGenerator")?.outputImage
	else {
		return image
	}
	
	bw.setValue(random, forKey: "inputImage")
	
	invert.setDefaults()
	invert.setValue(bw.outputImage, forKey: kCIInputImageKey)
	
	guard
		let monochromeNoise = invert.outputImage
	else { return image }
	
	unsharp.setDefaults()
	unsharp.setValue(monochromeNoise, forKey: kCIInputImageKey)
	unsharp.setValue(2, forKey: kCIInputRadiusKey)
	unsharp.setValue(10, forKey: kCIInputIntensityKey)
	
	let sharpenedMonochrome = unsharp.outputImage
	
	overlay.setValue(
		sharpenedMonochrome,
		forKey: kCIInputImageKey
	)
	overlay.setValue(
		CIVector(
			values: [0, 0, 0, presence == .high ? 0.35 : 0.20],
			count: 4
		),
		forKey: "inputAVector"
	)
	
	guard
		let noise = overlay
			.outputImage?
			.transformed(
				by: CGAffineTransform(
					scaleX: Double.random(in: 1...2),
					y: Double.random(in: 1...2)
				)
			)
			.transformed(
				by: .init(
					rotationAngle: Double.random(in: 1...360),
					anchor: .init(x: image.extent.midX, y: image.extent.midY)
				)
			)
	else { return image }
	
	blend.setValue(image, forKey: "inputBackgroundImage")
	blend.setValue(noise, forKey: "inputImage")
	
	return blend.outputImage?.cropped(to: image.extent) ?? image
}
