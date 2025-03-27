import AVFoundation
import ComposableArchitecture
import Core
import Foundation
import Shared
import UIKit

public protocol PipelineClient: AutoMockable {
	func createQRCode(data: Data, scale: CGFloat) -> Effect<CIImage, PipelineError>
	func convert(
		image: CIImage,
		aspectRatio: AspectRatio,
		context: CIContext,
		position: AVCaptureDevice.Position,
		transformation: Transformation
	) -> Effect<UIImage, PipelineError>
	func loadInitialData() async throws
	func parseQRCodesInImage(image: CIImage) -> Effect<[String], Never>
	func uiimage(image: CIImage) -> Effect<UIImage, PipelineError>
}

private enum PipelineClientKey: DependencyKey {
	static let liveValue: PipelineClient = LivePipelineClient(context: ciContext)
	static var testValue: PipelineClient = PipelineClientMock()
}

private enum PipelineQueueKey: DependencyKey {
	static let liveValue: AnyScheduler = AnySchedulerOf<DispatchQueue>(
		DispatchQueue(
			label: "com.eff.corp.aperture.pipelineQueue",
			qos: .userInitiated
		).eraseToAnyScheduler()
	)
	static var testValue: AnyScheduler = AnySchedulerOf<DispatchQueue>(
		DispatchQueue(
			label: "com.eff.corp.aperture.test.pipelineQueue",
			qos: .default
		).eraseToAnyScheduler()
	)
}

public extension DependencyValues {
	var pipelineClient: PipelineClient {
		get { self[PipelineClientKey.self] }
		set { self[PipelineClientKey.self] = newValue }
	}
	
	var pipelineQueue: AnySchedulerOf<DispatchQueue> {
		get { self[PipelineQueueKey.self] }
		set { self[PipelineQueueKey.self] = newValue }
	}
}

public final class LivePipelineClient: PipelineClient {
	
	// MARK: - Properties
	
	private let context: CIContext
	private let qrCodeDetector: CIDetector
	
	// MARK: - Lifecycle
	
	public init(context: CIContext) {
		self.context = context
		self.qrCodeDetector = CIDetector(
			ofType: CIDetectorTypeQRCode,
			context: context,
			options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]
		)!
	}
	
	// MARK: - PipelineClient
	
	public func createQRCode(
		data: Data,
		scale: CGFloat
	) -> Effect<CIImage, PipelineError> {
		.future { resolver in
			let colorParameters = [
				//Foreground Color
				"inputColor0": CIColor(color: UIColor.black),
				//Background Color
				"inputColor1": CIColor(color: UIColor.clear)
			]
			
			guard
				let filter = CIFilter(name: "CIQRCodeGenerator")
			else { return resolver(.failure(.invalidState)) }
			
			filter.setValue(data, forKey: "inputMessage")
			filter.setValue("Q", forKey: "inputCorrectionLevel")
			
			guard
				let output = filter.outputImage?
					.transformed(by: .init(scaleX: scale, y: scale))
					.applyingFilter("CIFalseColor", parameters: colorParameters)
			else { return resolver(.failure(.failedToGenerateImage)) }
			
			resolver(.success(output))
		}
	}
	
	public func convert(
		image: CIImage,
		aspectRatio: AspectRatio,
		context: CIContext,
		position: AVCaptureDevice.Position,
		transformation: Transformation
	) -> EffectPublisher<UIImage, PipelineError> {
		.future { resolver in
			if let image: UIImage = Pipeline.convert(
				img: image,
				aspectRatio: aspectRatio,
				context: context,
				position: position,
				transformation: transformation
			) {
				resolver(.success(image))
			}
			else {
				resolver(.failure(.failedToConvert))
			}
		}
	}
	
	public func loadInitialData() async throws {
		try await CubeTransformer.loadInitialPipelineData()
	}
	
	public func parseQRCodesInImage(
		image: CIImage
	) -> Effect<[String], Never> {
		.future { [weak self] resolver in
			guard let self = self else { return }
			let detected = self.qrCodeDetector.features(in: image)
				.compactMap { feature in
					(feature as? CIQRCodeFeature)?.messageString
				}
			
			resolver(.success(detected))
		}
	}
	
	public func uiimage(image: CIImage) -> Effect<UIImage, PipelineError> {
		.future { [weak self] resolver in
			guard
				let self = self,
				let cgimage = self.context.createCGImage(image, from: image.extent)
			else { return resolver(.failure(.failedToGenerateImage)) }
			
			resolver(.success(.init(cgImage: cgimage)))
		}
	}
}

public func convert(
	img: CIImage,
	aspectRatio: AspectRatio,
	context: CIContext,
	position: AVCaptureDevice.Position,
	transformation: Transformation
) -> UIImage? {
	var ciimage = img
	
		ciimage = transformation.transform(ciimage)
		
		switch transformation.preferredQuantization {
		case .chromatic(let chromaticTransformation):
			ciimage = CubeTransformer(
				image: ciimage,
				.chromatic(chromaticTransformation)
			).outputImage ?? ciimage
		case .dither:
			if let dithering = try? DitheringTransformer(
				image: ciimage,
				context: context
			).outputImage {
				ciimage = CIImage(cgImage: dithering)
			}
		case .monochrome:
			ciimage = CubeTransformer(
				image: ciimage,
				.monochromatic(position)
			).outputImage ?? ciimage
		case .warhol(let warhol):
			if let polynomial = try? PolynomialTransformer(
				image: ciimage,
				context: context,
				warhol: warhol
			).outputImage {
				ciimage = CIImage(cgImage: polynomial)
			}
		}
	
	let targetExtent = AVMakeRect(
		aspectRatio: aspectRatio.portrait,
		insideRect: ciimage.extent
	)
	
	guard
		let image = context.createCGImage(ciimage, from: targetExtent)
	else { return nil }
	
	return .init(cgImage: image)
}
