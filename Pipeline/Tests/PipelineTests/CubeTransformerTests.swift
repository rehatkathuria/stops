import XCTest

@testable import Pipeline

final class CubeTransformerTests: XCTestCase {
	
	// MARK: - Properties
	
	private let context: CIContext = {
		if let device = MTLCreateSystemDefaultDevice() {
			return CIContext(mtlDevice: device)
		} else {
			return CIContext()
		}
	}()
	
	// MARK: - Tests
	
	func testMononokeReference() throws {
		try compare(
			stringRepresentation: mononoke,
			data: try! Data(
				contentsOf: Bundle.module.url(
					forResource: "mononoke",
					withExtension: "png"
				)!
			)
		)
	}
	
	func testMononokeFrontReference() throws {
		try compare(
			stringRepresentation: mononokeFront,
			data: try! Data(
				contentsOf: Bundle.module.url(
					forResource: "mononoke-front",
					withExtension: "png"
				)!
			)
		)
	}
	
	func testMononokeFrontTwoReference() throws {
		try compare(
			stringRepresentation: mononokeFrontTwo,
			data: try! Data(
				contentsOf: Bundle.module.url(
					forResource: "mononoke-front-v2",
					withExtension: "png"
				)!
			)
		)
	}
	
	func testVertichromeReference() throws {
		try compare(
			stringRepresentation: vertichrome,
			data: try! Data(
				contentsOf: Bundle.module.url(
					forResource: "prt",
					withExtension: "png"
				)!
			)
		)
	}
	

	// MARK: - Comparison Helpers
	
	func compare(stringRepresentation: String, data: Data) throws {
		let image = CIImage(contentsOf: Bundle.module.url(forResource: "portrait", withExtension: "jpg")!)

		let prtFrom64 = colorCubeFilterFromBase64(stringRepresentation)!
		let chromaticData = colorCubeFilterFromLUT(.init(data: data)!)
		
		XCTAssertEqual(prtFrom64, chromaticData)
		
		guard
			let pngFilter = CIFilter(name: "CIColorCubeWithColorSpace"),
			let base64Filter = CIFilter(name: "CIColorCubeWithColorSpace")
		else { fatalError() }
		
		pngFilter.setDefaults()
		pngFilter.setValue(image, forKey: kCIInputImageKey)
		pngFilter.setValue(64, forKey: "inputCubeDimension")
		pngFilter.setValue(chromaticData, forKey: "inputCubeData")
		pngFilter.setValue(rgb, forKey: "inputColorSpace")

		base64Filter.setDefaults()
		base64Filter.setValue(image, forKey: kCIInputImageKey)
		base64Filter.setValue(64, forKey: "inputCubeDimension")
		base64Filter.setValue(prtFrom64, forKey: "inputCubeData")
		base64Filter.setValue(rgb, forKey: "inputColorSpace")
		
		let pngImage = UIImage(cgImage: context.createCGImage(pngFilter.outputImage!, from: pngFilter.outputImage!.extent)!)
		let baseImage = UIImage(cgImage: context.createCGImage(base64Filter.outputImage!, from: base64Filter.outputImage!.extent)!)
		
		let pngData = pngImage.pngData()
		let baseData = baseImage.pngData()
		
		XCTAssertNotNil(pngData)
		XCTAssertNotNil(baseData)
		XCTAssertEqual(pngData, baseData)
	}
}
