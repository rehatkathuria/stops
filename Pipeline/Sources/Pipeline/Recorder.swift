import AVFoundation
import Combine
import ComposableArchitecture
import Foundation
import Shared

public protocol RecorderDelegate: AnyObject {
	/// Fires when we receive the first valid video buffer
	func recorderDidBeginRecording(_ recorder: Recorder)
	
	/// Fires each time we update with a valid video buffer
	func recorderDidUpdateRecordingDuration(_ recorder: Recorder, duration: Measurement<UnitDuration>)
	
	/// Fires when we finish recording
	func recorderDidFinishRecording(_ recorder: Recorder)
}

public final class Recorder {

	// MARK: - Properties

	public weak var delegate: RecorderDelegate?
	
	public private(set) var isRecording = false
	private(set) var measurement: Measurement<UnitDuration> = .init(
		value: 0,
		unit: .seconds
	)

	private var assetWriter: AVAssetWriter?
	private var assetWriterVideoInput: AVAssetWriterInput?
	private var assetWriterAudioInput: AVAssetWriterInput?

	private var videoSettings: [String: Any]
	private var audioSettings: [String: Any]?
	private var videoTransform: CGAffineTransform

	private var startTime = Double(0)
	private var hasReceivedVideoBuffer = false

	// MARK: - Lifecycle

	public init(
		audioSettings: [String: Any]?,
		videoSettings: [String: Any],
		videoTransform: CGAffineTransform
	) {
		self.audioSettings = audioSettings
		self.videoSettings = videoSettings
		self.videoTransform = videoTransform
	}

	// MARK: - Recording

	public func startRecording(
		fileURL: URL,
		fileType: AVFileType,
		size: CGSize
	) {
		guard let writer = try? AVAssetWriter(url: fileURL, fileType: fileType) else { return }
		writer.shouldOptimizeForNetworkUse = true
		
//		audioSettings?[AVFormatIDKey] = kAudioFormatMPEG4AAC
//		audioSettings?[AVNumberOfChannelsKey] = 2
//		audioSettings?[AVSampleRateKey] = 44100
//		audioSettings?[AVEncoderBitRateKey] = 128000
//		
		if let audioSettings = audioSettings {
			let audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
			audioInput.expectsMediaDataInRealTime = true
			writer.add(audioInput)
			assetWriterAudioInput = audioInput
		}

		videoSettings[AVVideoCodecKey] = AVVideoCodecType.hevc
		videoSettings[AVVideoWidthKey] = size.width
		videoSettings[AVVideoHeightKey] = size.height
		videoSettings[AVVideoScalingModeKey] = AVVideoScalingModeResizeAspectFill
		
		let videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
		videoInput.expectsMediaDataInRealTime = true
		videoInput.transform = videoTransform
		writer.add(videoInput)
		assetWriterVideoInput = videoInput

		assetWriter = writer
		isRecording = true
	}

	public func stopRecording() async throws -> URL {
		guard
			let assetWriter = assetWriter,
			assetWriter.status != .unknown
		else { throw PipelineError.invalidState }

		self.isRecording = false
		self.assetWriter = nil
		self.delegate?.recorderDidFinishRecording(self)

		await assetWriter.finishWriting()
		return assetWriter.outputURL
	}

	public func recordVideo(sampleBuffer: CMSampleBuffer) {
		guard
			isRecording,
			let assetWriter = assetWriter
		else { return }

		if assetWriter.status == .unknown, let input = assetWriterVideoInput {
			assetWriter.startWriting()
			let startTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
			assetWriter.startSession(atSourceTime: startTimeStamp)
			startTime = Double(startTimeStamp.value) / Double(startTimeStamp.timescale)
			input.append(sampleBuffer)
		}
		else if assetWriter.status == .writing, let input = assetWriterVideoInput, input.isReadyForMoreMediaData {
			input.append(sampleBuffer)
			if hasReceivedVideoBuffer == false { delegate?.recorderDidBeginRecording(self) }
			hasReceivedVideoBuffer = true
			let currentTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
			let currentTime = Double(currentTimeStamp.value) / Double(currentTimeStamp.timescale)
			measurement.value = currentTime - startTime
			delegate?.recorderDidUpdateRecordingDuration(self, duration: measurement)
		}
	}

	public func recordAudio(sampleBuffer: CMSampleBuffer) {
		guard
			hasReceivedVideoBuffer,
			isRecording,
			let assetWriter = assetWriter,
			assetWriter.status == .writing,
			let input = assetWriterAudioInput,
			input.isReadyForMoreMediaData
		else { return }
		input.append(sampleBuffer)
	}

}

