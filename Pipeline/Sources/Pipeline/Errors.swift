import Foundation

enum Spectrum {
	case red, green, blue
}

public enum PipelineError: Error {
	case failedToGeneratePipeline
	case failedToBuildHistogram
	case failedToConvert
	case failedToGenerateImage
	case invalidState
}
