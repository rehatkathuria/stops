import ComposableArchitecture
import Foundation
import Photos

public enum AssetKind {
	case photo(Data)
	case video(URL)
}

public protocol ShoeboxClient {
	func attemptDeletion(_ asset: [PHAsset]) -> EffectTask<Void>
	func persistAsset(
		_ resource: AssetKind,
		addToPhotoLibrary: Bool,
		location: CLLocation?
	) -> EffectTask<Void>
	func toggleAssetFavourite(_ asset: PHAsset) -> EffectTask<PHAsset?>
}

public final class LiveShoeboxClient: ShoeboxClient {
	
	// MARK: - Properties
	
	private let albumName = "Stops"
	private var collection: PHAssetCollection?
	
	// MARK: - Lifecycle
	
	public init() { }
	
	// MARK: - ShoeboxClient
	
	public func attemptDeletion(_ asset: [PHAsset]) -> EffectTask<Void> {
		.task(priority: .utility) {
			let assetIdentifiers = asset.map(\.localIdentifier)
			let assets = PHAsset.fetchAssets(withLocalIdentifiers: assetIdentifiers, options: nil)
			
			try await PHPhotoLibrary.shared().performChanges {
				PHAssetChangeRequest.deleteAssets(assets)
			}
		}
	}
	
	public func persistAsset(
		_ resource: AssetKind,
		addToPhotoLibrary: Bool,
		location: CLLocation?
	) -> EffectTask<Void> {
		.task(priority: .utility) { @MainActor [weak self] in
			guard let self = self else { return }
			
			let permissions = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
			guard permissions != .denied || permissions != .notDetermined else { return }

			if addToPhotoLibrary { let _ = try? await self.createAlbumIfNeeded() }
			
			try await PHPhotoLibrary.shared().performChanges {
				let creation = PHAssetCreationRequest.forAsset()
				creation.location = location
				
				switch resource {
				case .photo(let data):
					creation.addResource(with: .photo, data: data, options: nil)
				case .video(let url):
					let options = PHAssetResourceCreationOptions.init()
					options.shouldMoveFile = true
					creation.addResource(with: .video, fileURL: url, options: options)
				}
				
				if addToPhotoLibrary, let album = self.collection, let albumChange = PHAssetCollectionChangeRequest(for: album), let placeholder = creation.placeholderForCreatedAsset {
					albumChange.addAssets(NSArray(object: placeholder))
				}
			}
		}
	}

	public func toggleAssetFavourite(_ asset: PHAsset) -> EffectTask<PHAsset?> {
		.task(priority: .utility) {
			guard
				let asset = PHAsset.fetchAssets(withLocalIdentifiers: [asset.localIdentifier], options: nil).firstObject
			else { return nil }
			
			try await PHPhotoLibrary.shared().performChanges {
				let change = PHAssetChangeRequest(for: asset)
				change.isFavorite = !asset.isFavorite;
			}
			
			guard
				let secondFetch = PHAsset.fetchAssets(withLocalIdentifiers: [asset.localIdentifier], options: nil).firstObject
			else { return nil }
			
			return secondFetch
		}
	}
	
	// MARK: - Helper Methods (Private)
	
	private func createAlbumIfNeeded() async throws -> Bool  {
		if let existing = existingAssetCollection() {
			collection = existing
			return true
		}
		try await PHPhotoLibrary.shared().performChanges { [weak self] in
			guard let self = self else { return }
			PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.albumName)
		}
		guard let new = existingAssetCollection() else { return false }
		collection = new
		return true
	}
	
	private func existingAssetCollection() -> PHAssetCollection? {
		let fetchOptions = PHFetchOptions()
		fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
		let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
		return collection.firstObject
	}
	
}

@MainActor
private enum ShoeboxClientKey: DependencyKey {
	static let liveValue: ShoeboxClient = LiveShoeboxClient()
}

public extension DependencyValues {
	var shoeboxClient: ShoeboxClient {
		get { self[ShoeboxClientKey.self] }
		set { self[ShoeboxClientKey.self] = newValue }
	}
}
