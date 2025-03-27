import Accelerate
import AVFoundation
import ComposableArchitecture
import CoreImage
import Foundation
import Shared
import UIKit

public final class CubeTransformer {
	
	// MARK: - Substructures
	
	public enum Preset {
		case chromatic(ChromaticTransformation)
		case monochromatic(AVCaptureDevice.Position)
	}
	
	// MARK: - Properties (Static and Internal)
	
	private static var chromaticFoliaData: NSData?
	private static var chromaticSupergoldData: NSData?
	private static var chromaticTonachromeData: NSData?
	private static var monochromaticData: NSData?
	private static var monochromaticFrontData: NSData?

	public internal(set) var outputImage: CIImage?
	
	// MARK: - Lifecycle
	
	public init(
		image: CIImage,
		_ preset: Preset
	) {
		guard
			let filter = CIFilter(name: "CIColorCubeWithColorSpace")
		else { fatalError() }
		
		filter.setDefaults()
		filter.setValue(image, forKey: kCIInputImageKey)
		filter.setValue(64, forKey: "inputCubeDimension")
		switch preset {
		case .chromatic(let transformation):
			switch transformation {
			case .folia:
				guard let _ = CubeTransformer.chromaticFoliaData else { return }
				filter.setValue(CubeTransformer.chromaticFoliaData, forKey: "inputCubeData")
				
			case .supergold:
				guard let _ = CubeTransformer.chromaticSupergoldData else { return }
				filter.setValue(CubeTransformer.chromaticSupergoldData, forKey: "inputCubeData")
				
			case .tonachrome:
				guard let _ = CubeTransformer.chromaticTonachromeData else { return }
				filter.setValue(CubeTransformer.chromaticTonachromeData, forKey: "inputCubeData")
			}
		case .monochromatic(let position):
			switch position {
			case .front:
				guard let _ = CubeTransformer.monochromaticFrontData else { return }
				filter.setValue(CubeTransformer.monochromaticFrontData, forKey: "inputCubeData")
			case .unspecified, .back:
				guard let _ = CubeTransformer.monochromaticData else { return }
				filter.setValue(CubeTransformer.monochromaticData, forKey: "inputCubeData")
			@unknown default:
				guard let _ = CubeTransformer.monochromaticData else { return }
				filter.setValue(CubeTransformer.monochromaticData, forKey: "inputCubeData")
			}
		}
		filter.setValue(rgb, forKey: "inputColorSpace")

		outputImage = filter.outputImage
	}
	
	deinit {
		outputImage = nil
	}
	
	// MARK: - Helpers
	
	public static func loadInitialPipelineData() async throws {
		if (CubeTransformer.chromaticFoliaData == nil) { CubeTransformer.chromaticFoliaData = colorCubeFilterFromBase64(folia) }
		if (CubeTransformer.chromaticSupergoldData == nil) { CubeTransformer.chromaticSupergoldData = colorCubeFilterFromBase64(supergold) }
		if (CubeTransformer.chromaticTonachromeData == nil) { CubeTransformer.chromaticTonachromeData = colorCubeFilterFromBase64(vertichrome) }
		if (CubeTransformer.monochromaticData == nil) { CubeTransformer.monochromaticData = colorCubeFilterFromBase64(mononoke) }
		if (CubeTransformer.monochromaticFrontData == nil) { CubeTransformer.monochromaticFrontData = colorCubeFilterFromBase64(mononokeFrontTwo) }
		
		guard
			let _ = CubeTransformer.chromaticFoliaData,
			let _ = CubeTransformer.chromaticSupergoldData,
			let _ = CubeTransformer.chromaticTonachromeData,
			let _ = CubeTransformer.monochromaticData,
			let _ = CubeTransformer.monochromaticFrontData
		else { throw PipelineError.failedToGeneratePipeline }
	}
	
}
