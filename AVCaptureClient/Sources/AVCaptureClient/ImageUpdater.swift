import Combine
import ComposableArchitecture
import Foundation
import SwiftUI

public class ImageUpdater: ObservableObject {
	public static let shared = ImageUpdater()
	
	@Dependency(\.avCaptureClient) var avCaptureClient
	@Dependency(\.pipelineQueue) var pipelineQueue
	@Dependency(\.mainQueue) var mainQueue
	
	@Published public var previewImage: UIImage?
	@Published public var redactedPreviewImage: UIImage?
	
	private var cancellables = Set<AnyCancellable>()
	
	public init() {
		avCaptureClient.previewImagePublisher
			.subscribe(on: pipelineQueue)
			.receive(on: mainQueue)
			.sink(receiveValue: { [weak self] value in
				guard let self else { return }
				self.previewImage = value.rawValue
			})
			.store(in: &cancellables)

		avCaptureClient.redactedPreviewImagePublisher
			.subscribe(on: pipelineQueue)
			.receive(on: mainQueue)
			.sink(receiveValue: { [weak self] value in
				guard let self else { return }
				self.redactedPreviewImage = value.rawValue
			})
			.store(in: &cancellables)
	}
}
