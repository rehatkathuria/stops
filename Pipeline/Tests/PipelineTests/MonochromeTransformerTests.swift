import XCTest

@testable import Pipeline

final class MonochromeTransformerTests: XCTestCase {
	
	// MARK: - Properties
	private let context: CIContext = {
		if let device = MTLCreateSystemDefaultDevice() {
			 return CIContext(mtlDevice: device)
		 } else {
			 return CIContext()
		 }
	 }()
	
	// MARK: - Tests
	
	func testDefaultConversion() throws {
		let url = Bundle.module.url(forResource: "portrait", withExtension: "jpg")!
		let portrait = CIImage(contentsOf: url)!
		
		let transformer = try Pipeline.MonochromeTransformer(
			image: portrait,
			context: context
		)
	}
}
