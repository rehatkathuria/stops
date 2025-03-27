// Generated using Sourcery 1.8.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Shared


import Foundation

#if canImport(AVFoundation)
import AVFoundation
#endif

#if canImport(Combine)
import Combine
#endif

#if canImport(ComposableArchitecture)
import ComposableArchitecture
#endif

#if canImport(CoreImage)
import CoreImage
#endif

#if canImport(UIKit)
import UIKit
#endif

public final class PipelineClientMock: PipelineClient, @unchecked Sendable {
    public init() {}

    //MARK: - createQRCode

    public var createQRCodeDataScaleCallsCount = 0
    public var createQRCodeDataScaleCalled: Bool {
        return createQRCodeDataScaleCallsCount > 0
    }
    public var createQRCodeDataScaleReceivedArguments: (data: Data, scale: CGFloat)?
    public var createQRCodeDataScaleReturnValue: Effect<CIImage, PipelineError>!
    public var createQRCodeDataScaleClosure: ((Data, CGFloat) -> Effect<CIImage, PipelineError>)?
    public var createQRCodeDataScaleQueue = DispatchQueue(label: "createQRCodeDataScaleQueue")

    public func createQRCode(data: Data, scale: CGFloat) -> Effect<CIImage, PipelineError> {
        createQRCodeDataScaleQueue.sync {
            createQRCodeDataScaleCallsCount += 1
            createQRCodeDataScaleReceivedArguments = (data: data, scale: scale)
            return createQRCodeDataScaleClosure.map({ $0(data, scale) }) ?? createQRCodeDataScaleReturnValue
        }
    }

    //MARK: - convert

    public var convertImageAspectRatioContextPositionTransformationCallsCount = 0
    public var convertImageAspectRatioContextPositionTransformationCalled: Bool {
        return convertImageAspectRatioContextPositionTransformationCallsCount > 0
    }
    public var convertImageAspectRatioContextPositionTransformationReceivedArguments: (image: CIImage, aspectRatio: AspectRatio, context: CIContext, position: AVCaptureDevice.Position, transformation: Transformation)?
    public var convertImageAspectRatioContextPositionTransformationReturnValue: Effect<UIImage, PipelineError>!
    public var convertImageAspectRatioContextPositionTransformationClosure: ((CIImage, AspectRatio, CIContext, AVCaptureDevice.Position, Transformation) -> Effect<UIImage, PipelineError>)?
    public var convertImageAspectRatioContextPositionTransformationQueue = DispatchQueue(label: "convertImageAspectRatioContextPositionTransformationQueue")

    public func convert(image: CIImage, aspectRatio: AspectRatio, context: CIContext, position: AVCaptureDevice.Position, transformation: Transformation) -> Effect<UIImage, PipelineError> {
        convertImageAspectRatioContextPositionTransformationQueue.sync {
            convertImageAspectRatioContextPositionTransformationCallsCount += 1
            convertImageAspectRatioContextPositionTransformationReceivedArguments = (image: image, aspectRatio: aspectRatio, context: context, position: position, transformation: transformation)
            return convertImageAspectRatioContextPositionTransformationClosure.map({ $0(image, aspectRatio, context, position, transformation) }) ?? convertImageAspectRatioContextPositionTransformationReturnValue
        }
    }

    //MARK: - loadInitialData

    public var loadInitialDataThrowableError: Error?
    public var loadInitialDataCallsCount = 0
    public var loadInitialDataCalled: Bool {
        return loadInitialDataCallsCount > 0
    }
    public var loadInitialDataClosure: (() throws -> Void)?
    public var loadInitialDataQueue = DispatchQueue(label: "loadInitialDataQueue")

    public func loadInitialData() throws {
        try loadInitialDataQueue.sync {
            loadInitialDataCallsCount += 1
        if let error = loadInitialDataThrowableError {
            throw error
        }
            try loadInitialDataClosure?()
        }
    }

    //MARK: - parseQRCodesInImage

    public var parseQRCodesInImageImageCallsCount = 0
    public var parseQRCodesInImageImageCalled: Bool {
        return parseQRCodesInImageImageCallsCount > 0
    }
    public var parseQRCodesInImageImageReceivedImage: CIImage?
    public var parseQRCodesInImageImageReturnValue: Effect<[String], Never>!
    public var parseQRCodesInImageImageClosure: ((CIImage) -> Effect<[String], Never>)?
    public var parseQRCodesInImageImageQueue = DispatchQueue(label: "parseQRCodesInImageImageQueue")

    public func parseQRCodesInImage(image: CIImage) -> Effect<[String], Never> {
        parseQRCodesInImageImageQueue.sync {
            parseQRCodesInImageImageCallsCount += 1
        parseQRCodesInImageImageReceivedImage = image
            return parseQRCodesInImageImageClosure.map({ $0(image) }) ?? parseQRCodesInImageImageReturnValue
        }
    }

    //MARK: - uiimage

    public var uiimageImageCallsCount = 0
    public var uiimageImageCalled: Bool {
        return uiimageImageCallsCount > 0
    }
    public var uiimageImageReceivedImage: CIImage?
    public var uiimageImageReturnValue: Effect<UIImage, PipelineError>!
    public var uiimageImageClosure: ((CIImage) -> Effect<UIImage, PipelineError>)?
    public var uiimageImageQueue = DispatchQueue(label: "uiimageImageQueue")

    public func uiimage(image: CIImage) -> Effect<UIImage, PipelineError> {
        uiimageImageQueue.sync {
            uiimageImageCallsCount += 1
        uiimageImageReceivedImage = image
            return uiimageImageClosure.map({ $0(image) }) ?? uiimageImageReturnValue
        }
    }

}
