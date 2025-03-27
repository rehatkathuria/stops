import AVFoundation
import Foundation
import SwiftUI
import UIKit

public struct PrivateImageView: UIViewRepresentable {
	public typealias UIViewType = UIPrivateImageView
	private let frame: CGRect
	private let image: UIImage?
	private let contentMode: AVLayerVideoGravity
	
	public init(frame: CGRect, image: UIImage?, contentMode: AVLayerVideoGravity) {
		self.frame = frame
		self.image = image
		self.contentMode = contentMode
	}
	
	public func makeUIView(context: Context) -> UIPrivateImageView {
		let view = UIPrivateImageView(frame: frame)
		view.imageContentMode = contentMode
		return view
	}
	
	public func updateUIView(_ uiView: UIPrivateImageView, context: Context) {
		guard image != uiView.image else { return }
		uiView.updateImage(to: image)
	}
}

public final class UIPrivateImageView: UIView {
	public var image: UIImage?
	
	public init(
		frame: CGRect,
		image: UIImage? = nil
	) {
		super.init(frame: frame)
		self.layer.masksToBounds = true
		self.clipsToBounds = true
		self.layer.preventsCapture = true
		image.flatMap(self.updateImage(to:))
		self.image = image
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override class var layerClass: AnyClass {
		AVSampleBufferDisplayLayer.self
	}
	
	public override var layer: AVSampleBufferDisplayLayer {
		super.layer as! AVSampleBufferDisplayLayer
	}
	
	public var preventsCapture: Bool {
		get { self.layer.preventsCapture }
		set { self.layer.preventsCapture = newValue }
	}
	
	public var imageContentMode: AVLayerVideoGravity {
		get { self.layer.videoGravity }
		set { self.layer.videoGravity = newValue }
	}
	
	@MainActor
	public func updateImage(to image: UIImage?) {
		self.layer.flush()
		guard let sampleBuffer = image?.cgImage?.sampleBuffer else { return }
		self.image = image
		self.layer.enqueue(sampleBuffer)
	}
}

import CoreGraphics
import CoreVideo

extension CGImage {
	public var sampleBuffer: CMSampleBuffer? {
		guard let pixelBuffer = self.pixelBuffer else { return nil }
		CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
		defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }
		
		guard let formatDescription = try? CMVideoFormatDescription(imageBuffer: pixelBuffer) else { return nil }
		let timingInfo = CMSampleTimingInfo(
			duration: CMTime(value: 1, timescale: 30),
			presentationTimeStamp: .zero,
			decodeTimeStamp: .invalid
		)
		return try? CMSampleBuffer(
			imageBuffer: pixelBuffer,
			formatDescription: formatDescription,
			sampleTiming: timingInfo
		)
	}
	
	public func sampleBuffer(timingInfo: CMSampleTimingInfo) -> CMSampleBuffer? {
		guard let pixelBuffer = self.pixelBuffer else { return nil }
		CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
		defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }
		
		guard let formatDescription = try? CMVideoFormatDescription(imageBuffer: pixelBuffer) else { return nil }
		return try? CMSampleBuffer(
			imageBuffer: pixelBuffer,
			formatDescription: formatDescription,
			sampleTiming: timingInfo
		)
	}
	
	var pixelBuffer: CVPixelBuffer? {
		var pixelBuffer: CVPixelBuffer? = nil
		let ioSurfaceProperties = NSMutableDictionary()
		let options = NSMutableDictionary()
		options.setObject(ioSurfaceProperties, forKey: kCVPixelBufferIOSurfacePropertiesKey as NSString)
		
		CVPixelBufferCreate(
			kCFAllocatorDefault,
			Int(self.width),
			Int(self.height),
			kCVPixelFormatType_32ARGB,
			options as CFDictionary,
			&pixelBuffer
		)
		
		guard let pixelBuffer = pixelBuffer else { return nil }
		
		CVPixelBufferLockBaseAddress(pixelBuffer, [])
		defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }
		
		let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
		guard let context = CGContext(
			data: baseAddress,
			width: Int(self.width),
			height: Int(self.height),
			bitsPerComponent: 8,
			bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
			space: CGColorSpaceCreateDeviceRGB(),
			bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
		) else { return nil }
		
		let frame = CGRect(
			origin: .zero,
			size: CGSize(width: self.width, height: self.height)
		)
		context.clear(frame)
		context.draw(self, in: frame)
		
		return pixelBuffer
	}
}
