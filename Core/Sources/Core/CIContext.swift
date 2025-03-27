import CoreImage
import Dependencies
import Foundation

public let ciContext: CIContext = {
	if let device = MTLCreateSystemDefaultDevice() {
		return CIContext(mtlDevice: device)
	} else {
		return CIContext()
	}
}()

private enum CIContextKey: DependencyKey {
	static let liveValue: CIContext = ciContext
	static var testValue: CIContext = CIContext()
}

public extension DependencyValues {
	var ciContext: CIContext {
		get { self[CIContextKey.self] }
		set { self[CIContextKey.self] = newValue }
	}
}
