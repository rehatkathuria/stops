import Accelerate
import CoreImage
import Foundation
import UIKit

// MARK: - Properties

let rgb = CGColorSpaceCreateDeviceRGB()

// MARK: - LUT Conversion Methods

func colorCubeFilterFromBase64(_ string: String) -> NSData? {
	guard
		let baseData = Data(base64Encoded: string),
		let lut3DImage = UIImage(data: baseData)
	else { return nil }
	return colorCubeFilterFromLUT(lut3DImage)
}

func colorCubeFilterFromLUT(_ image: UIImage) -> NSData? {
	let size = Float(64)
	
	let lutImage    = image
	let lutWidth    = Float(lutImage.size.width)
	let lutHeight   = Float(lutImage.size.height)
	let rowCount    = lutHeight / size
	let columnCount = lutWidth / size
	
	if ((lutWidth.truncatingRemainder(dividingBy: size) != 0) || (lutHeight.truncatingRemainder(dividingBy: size) != 0) || (rowCount * columnCount != size)) {
		return nil
	}
	
	let bitmap  = getBytesFromImage(image: image)!
	let floatSize = MemoryLayout<Float>.size
	
	let cubeData = UnsafeMutablePointer<Float>.allocate(
		capacity: Int(size * size * size * 4 * Float(floatSize))
	)
	var z = Float(0.0)
	var bitmapOffset = Int(0)
	
	for _ in 0 ..< Int(rowCount) {
		for y in 0 ..< Int(size) {
			let tmp = z
			for _ in 0 ..< Int(columnCount) {
				for x in 0 ..< Int(size) {
					
					let alpha   = Float(bitmap[bitmapOffset]) / 255.0
					let red     = Float(bitmap[bitmapOffset+1]) / 255.0
					let green   = Float(bitmap[bitmapOffset+2]) / 255.0
					let blue    = Float(bitmap[bitmapOffset+3]) / 255.0
					
					let first = z * size * size
					let ySize = Float(y) * size
					let dataOffset = Int((first + ySize + Float(x)) * 4)
					
					cubeData[dataOffset + 3] = alpha
					cubeData[dataOffset + 2] = red
					cubeData[dataOffset + 1] = green
					cubeData[dataOffset + 0] = blue
					bitmapOffset += 4
				}
				z += 1
			}
			z = tmp
		}
		z += columnCount
	}
	
	return NSData(
		bytesNoCopy: cubeData,
		length: Int(size * size * size) * 4 * floatSize,
		freeWhenDone: true
	)
}

func getBytesFromImage(image:UIImage?) -> [UInt8]? {
	var pixelValues: [UInt8]?
	if let imageRef = image?.cgImage {
		let width = Int(imageRef.width)
		let height = Int(imageRef.height)
		let bitsPerComponent = 8
		let bytesPerRow = width * 4
		let totalBytes = height * bytesPerRow
		
		let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		var intensities = [UInt8](repeating: 0, count: totalBytes)
		
		let contextRef = CGContext(data: &intensities, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
		contextRef?.draw(imageRef, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height)))
		
		pixelValues = intensities
	}
	return pixelValues!
}

// MARK: - Deprecated

@available(*, deprecated, message: "Please use colorCubeFilterFromLUT(:) instead")
private func cubeDataForLut64(_ lutImage: CIImage) -> Data? {
	let cubeDimension = 64
	let cubeSize = (cubeDimension * cubeDimension * cubeDimension * MemoryLayout<Float>.size * 4)
	
	let imageWidth = Int(lutImage.extent.width)
	let imageHeight = Int(lutImage.extent.height)
	let rowCount = imageHeight / cubeDimension
	let columnCount = imageWidth / cubeDimension
	
	guard ((imageWidth % cubeDimension == 0) || (imageHeight % cubeDimension == 0) || (rowCount * columnCount == cubeDimension)) else {
		print("Invalid LUT")
		return nil
	}
	
	let bitmapData = createRGBABitmapFromImage(lutImage)
	let cubeData = UnsafeMutablePointer<Float>.allocate(capacity: cubeSize)
	
	var bitmapOffset: Int = 0
	var z: Int = 0
	for _ in 0 ..< rowCount{ // ROW
		for y in 0 ..< cubeDimension{
			let tmp = z
			for _ in 0 ..< columnCount{ // COLUMN
				let dataOffset = (z * cubeDimension * cubeDimension + y * cubeDimension) * 4
				var divider: Float = 255.0
				vDSP_vsdiv(&bitmapData[bitmapOffset], 1, &divider, &cubeData[dataOffset], 1, UInt(cubeDimension) * 4)
				bitmapOffset += cubeDimension * 4
				z += 1
			}
			z = tmp
		}
		z += columnCount
	}
	
	free(bitmapData)
	return Data(bytesNoCopy: cubeData, count: cubeSize, deallocator: .free)
}

fileprivate func createRGBABitmapFromImage(_ image: CIImage) -> UnsafeMutablePointer<Float> {
	let bitsPerPixel = 32
	let bitsPerComponent = 8
	let bytesPerPixel = bitsPerPixel / bitsPerComponent // 4 bytes = RGBA
	
	let imageWidth = Int(image.extent.width)
	let imageHeight = Int(image.extent.height)
	
	let bitmapBytesPerRow = imageWidth * bytesPerPixel
	let bitmapByteCount = bitmapBytesPerRow * imageHeight
	
	let colorSpace = CGColorSpaceCreateDeviceRGB()
	
	let bitmapData = malloc(bitmapByteCount)
	let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue).rawValue
	
	let context = CGContext(data: bitmapData, width: imageWidth, height: imageHeight, bitsPerComponent: bitsPerComponent, bytesPerRow: bitmapBytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
	
	let rect = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
	
	let ci = CIContext()
	let cg = ci.createCGImage(image, from: image.extent)!
	context?.draw(cg, in: rect)
	
	// Convert UInt8 byte array to single precision Float's
	let convertedBitmap = malloc(bitmapByteCount * MemoryLayout<Float>.size)
	vDSP_vfltu8(UnsafePointer<UInt8>(bitmapData!.assumingMemoryBound(to: UInt8.self)), 1,
							UnsafeMutablePointer<Float>(convertedBitmap!.assumingMemoryBound(to: Float.self)), 1,
							vDSP_Length(bitmapByteCount))
	
	free(bitmapData)
	
	return UnsafeMutablePointer<Float>(convertedBitmap!.assumingMemoryBound(to: Float.self))
}
