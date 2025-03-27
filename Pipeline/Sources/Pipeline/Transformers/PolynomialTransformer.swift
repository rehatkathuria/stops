import Accelerate
import CoreImage
import Foundation
import Shared

public final class PolynomialTransformer {
	
	// MARK: - Properties (Static and Internal)
	
	public internal(set) var outputImage: CGImage?
	private static let count = 5
	
	// MARK: - Properties (Formats)
	
	private let colorImageFormat = vImage_CGImageFormat(
		bitsPerComponent: 8,
		bitsPerPixel: 32,
		colorSpace: rgb,
		bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue)
	)!
	
	// MARK: - Properties (Buffers)
	
	private var sourceFullImageBuffer: vImage_Buffer?
	
	private var planarRedSourceBuffer: vImage_Buffer?
	private var planarGreenSourceBuffer: vImage_Buffer?
	private var planarBlueSourceBuffer: vImage_Buffer?
	private var planarRedDestinationBuffer: vImage_Buffer?
	private var planarGreenDestinationBuffer: vImage_Buffer?
	private var planarBlueDestinationBuffer: vImage_Buffer?
	private var planarAlphaBuffer: vImage_Buffer?
	
	// MARK: - Properties (Coefficients)
	
	private var redCoefficients = [Float](
		repeating: 0,
		count: PolynomialTransformer.count
	)
	private var redValues: [Double] = []
	
	private var greenCoefficients = [Float](
		repeating: 0,
		count: PolynomialTransformer.count
	)
	private var greenValues: [Double] = []
	
	private var blueCoefficients = [Float](
		repeating: 0,
		count: PolynomialTransformer.count
	)
	private var blueValues: [Double] = []
	
	// MARK: - Lifecycle
	
	public init(
		image: CIImage,
		context: CIContext,
		warhol: WarholTransformation
	) throws {
		guard
			let fullImage = context.createCGImage(
				image,
				from: image.extent
			)
		else { throw PipelineError.failedToConvert }
		
		sourceFullImageBuffer = try? vImage_Buffer(
			cgImage: fullImage
		)
		
		let size = image.extent.size
		planarRedSourceBuffer = try? vImage_Buffer(
			size: size,
			bitsPerPixel: colorImageFormat.bitsPerPixel
		)
		planarGreenSourceBuffer = try? vImage_Buffer(
			size: size,
			bitsPerPixel: colorImageFormat.bitsPerPixel
		)
		planarBlueSourceBuffer = try? vImage_Buffer(
			size: size,
			bitsPerPixel: colorImageFormat.bitsPerPixel
		)
		
		planarRedDestinationBuffer = try? vImage_Buffer(
			size: size,
			bitsPerPixel: colorImageFormat.bitsPerPixel
		)
		planarGreenDestinationBuffer = try? vImage_Buffer(
			size: size,
			bitsPerPixel: colorImageFormat.bitsPerPixel
		)
		planarBlueDestinationBuffer = try? vImage_Buffer(
			size: size,
			bitsPerPixel: colorImageFormat.bitsPerPixel
		)
		planarAlphaBuffer = try? vImage_Buffer(
			size: size,
			bitsPerPixel: colorImageFormat.bitsPerPixel
		)
		
		guard
			let _ = planarRedSourceBuffer,
			let _ = planarGreenSourceBuffer,
			let _ = planarBlueSourceBuffer,
			let _ = planarRedDestinationBuffer,
			let _ = planarGreenDestinationBuffer,
			let _ = planarBlueDestinationBuffer,
			let _ = planarAlphaBuffer
		else { throw PipelineError.failedToConvert }
		
		redValues = vDSP.ramp(
			in: 0 ... 255,
			count: PolynomialTransformer.count
		)
		greenValues = vDSP.ramp(
			in: 0 ... 255,
			count: PolynomialTransformer.count
		)
		blueValues = vDSP.ramp(
			in: 0 ... 255,
			count: PolynomialTransformer.count
		)
		
		switch warhol {
		case .bubblegum:
			vDSP.fill(&redValues, with: 255.0)
			greenValues = vDSP.ramp(
				in: 0 ... 255,
				count: PolynomialTransformer.count
			)
			vDSP.fill(&blueValues, with: 255.0)
		case .darkroom:
			vDSP.fill(&redValues, with: 255.0)
			greenValues = vDSP.ramp(
				in: 0 ... 255,
				count: PolynomialTransformer.count
			)
			blueValues = vDSP.ramp(
				in: 0 ... 255,
				count: PolynomialTransformer.count
			)

		case .glowInTheDark:
			vDSP.fill(&redValues, with: 0)
			greenValues = vDSP.ramp(
				in: 0 ... 200,
				count: PolynomialTransformer.count
			).map({ 200 - $0 })
			blueValues = vDSP.ramp(
				in: 0 ... 255,
				count: PolynomialTransformer.count
			).map({ 200 - $0 })

		case .habenero:
			vDSP.fill(&redValues, with: 255.0)
			greenValues = vDSP.ramp(
				in: 0 ... 255,
				count: PolynomialTransformer.count
			)
			vDSP.fill(&blueValues, with: 0)
	}
		
		var maxFloats: [Float] = [255, 255, 255, 255]
		var minFloats: [Float] = [0, 0, 0, 0]
		
		vImageConvert_ARGB8888toPlanarF(
			&sourceFullImageBuffer!,
			&planarRedSourceBuffer!,
			&planarGreenSourceBuffer!,
			&planarBlueSourceBuffer!,
			&planarAlphaBuffer!,
			&maxFloats, &minFloats,
			vImage_Flags(kvImageNoFlags)
		)
		
		try applyPolynomial(
			bins: [],
			values: redValues,
			source: &planarRedSourceBuffer!,
			coefficientsDestination: &redCoefficients,
			destination: &planarRedDestinationBuffer!,
			spectrum: .red
		)
		
		try applyPolynomial(
			bins: [],
			values: greenValues,
			source: &planarGreenSourceBuffer!,
			coefficientsDestination: &greenCoefficients,
			destination: &planarGreenDestinationBuffer!,
			spectrum: .green
		)
		
		try applyPolynomial(
			bins: [],
			values: blueValues,
			source: &planarBlueSourceBuffer!,
			coefficientsDestination: &blueCoefficients,
			destination: &planarBlueDestinationBuffer!,
			spectrum: .blue
		)
		
		var max: [Float] = [255, 255, 255, 255]
		var min: [Float] = [0, 0, 0, 0]
		
		vImageConvert_PlanarFToARGB8888(
			&planarRedDestinationBuffer!,
			&planarGreenDestinationBuffer!,
			&planarBlueDestinationBuffer!,
			&planarAlphaBuffer!,
			&sourceFullImageBuffer!,
			&max, &min,
			vImage_Flags(kvImageNoFlags)
		)
		
		outputImage = try? sourceFullImageBuffer?.createCGImage(
			format: colorImageFormat
		)
		
		sourceFullImageBuffer?.free()
		sourceFullImageBuffer = nil
	}
	
	private func applyPolynomial(
		bins: [vImagePixelCount],
		values: [Double],
		source: inout vImage_Buffer,
		coefficientsDestination: inout [Float],
		destination: inout vImage_Buffer,
		spectrum: Spectrum
	) throws {
		coefficientsDestination = try calculateCoefficients(
			bins: bins,
			values: values,
			spectrum: spectrum
		).map(Float.init)
		
		coefficientsDestination.withUnsafeBufferPointer { coefficientsPtr in
			var coefficientsBaseAddress = coefficientsPtr.baseAddress
			vImagePiecewisePolynomial_PlanarF(
				&source,
				&destination,
				&coefficientsBaseAddress,
				[-.infinity, .infinity],
				UInt32(coefficientsDestination.count - 1),
				0,
				vImage_Flags(kvImageNoFlags)
			)
		}
	}
	
	private func calculateCoefficients(
		bins: [vImagePixelCount],
		values: [Double],
		spectrum: Spectrum
	) throws -> [Double] {
		var a = vandermonde(bins, spectrum).flatMap { $0 }
		var b = values
		
		try PolynomialTransformer.solveLinearSystem(
			a: &a,
			a_rowCount: values.count,
			a_columnCount: values.count,
			b: &b,
			b_count: values.count
		)
		
		return b
	}
	
	private func vandermonde(
		_ bins: [vImagePixelCount],
		_ spectrum: Spectrum
	) -> [[Double]] {
		return vDSP
			.ramp(
				in: Double(0) ... 255,
				count: PolynomialTransformer.count
			)
			.map({ base in
				let bases = [Double](
					repeating: base,
					count: PolynomialTransformer.count
				)
				let exponents = vDSP.ramp(
					in: Double() ... Double(PolynomialTransformer.count - 1),
					count: PolynomialTransformer.count
				)
				
				return vForce.pow(
					bases: bases,
					exponents: exponents
				)
			})
	}
	
	deinit {
		sourceFullImageBuffer?.free()
		sourceFullImageBuffer = nil
		
		planarRedSourceBuffer?.free()
		planarRedSourceBuffer = nil
		
		planarGreenSourceBuffer?.free()
		planarGreenSourceBuffer = nil
		
		planarBlueSourceBuffer?.free()
		planarBlueSourceBuffer = nil
		
		planarRedDestinationBuffer?.free()
		planarRedDestinationBuffer = nil
		
		planarGreenDestinationBuffer?.free()
		planarGreenDestinationBuffer = nil
		
		planarBlueDestinationBuffer?.free()
		planarBlueDestinationBuffer = nil
		
		planarAlphaBuffer?.free()
		planarAlphaBuffer = nil
		
		outputImage = nil
	}
	
	static func solveLinearSystem(
		a: inout [Double],
		a_rowCount: Int, a_columnCount: Int,
		b: inout [Double],
		b_count: Int
	) throws {
		var info = Int32(0)
		var trans = Int8("T".utf8.first!)
		
		var m = __CLPK_integer(a_rowCount)
		var n = __CLPK_integer(a_columnCount)
		var lda = __CLPK_integer(a_rowCount)
		var nrhs = __CLPK_integer(1)
		var ldb = __CLPK_integer(b_count)
		
		var workDimension = Double(0)
		var minusOne = Int32(-1)
		
		dgels_(
			&trans,
			&m,
			&n,
			&nrhs,
			&a,
			&lda,
			&b,
			&ldb,
			&workDimension,
			&minusOne,
			&info
		)
		
		if info != 0 {
			throw LAPACKError.internalError
		}
		
		var lwork = Int32(workDimension)
		var workspace = [Double](
			repeating: 0,
			count: Int(workDimension)
		)
		
		dgels_(
			&trans,
			&m,
			&n,
			&nrhs,
			&a,
			&lda,
			&b,
			&ldb,
			&workspace,
			&lwork,
			&info
		)
		
		if info < 0 {
			throw LAPACKError.parameterHasIllegalValue(parameterIndex: abs(Int(info)))
		} else if info > 0 {
			throw LAPACKError.diagonalElementOfTriangularFactorIsZero(index: Int(info))
		}
	}
	
	public enum LAPACKError: Swift.Error {
		case internalError
		case parameterHasIllegalValue(parameterIndex: Int)
		case diagonalElementOfTriangularFactorIsZero(index: Int)
	}
}

