import Combine
import ComposableArchitecture
import Foundation
import Photos
import IdentifiedCollections
import UIKit

internal final class AssetsHolder: NSObject, PHPhotoLibraryChangeObserver {
	
	public var assetsDidUpdateNotifier: AnyPublisher<Void, Never> {
		assetsDidUpdateNotifierSubject.eraseToAnyPublisher()
	}
	
	public private(set) var assets = PHFetchResult<PHAsset>()
	
	private let viewStore: ViewStoreOf<GalleryFeature>
	private var assetsDidUpdateNotifierSubject = PassthroughSubject<Void, Never>()
	
	private let assetsParsingQueue = DispatchQueue(
		label: "com.eff.corp.aperture.gallery.assets.parsing.queue",
		qos: .default
	)
	
	private var hasRegisteredAsObserver = false
	private var cancellables = Set<AnyCancellable>()
	
	// MARK: - Lifecycle

	public init(
		store: StoreOf<GalleryFeature>
	) {
		self.viewStore = .init(store)
		super.init()
		
		viewStore.publisher
			.permissionState
			.filter({ $0 == .allowed })
			.removeDuplicates()
			.sink { [weak self] _ in
				self?.setNeedsUpdateDataSourceFiltering()
			}
			.store(in: &cancellables)
		
		viewStore.publisher
			.galleryFilter
			.removeDuplicates()
			.sink { [weak self] _ in
				self?.setNeedsUpdateDataSourceFiltering()
			}
			.store(in: &cancellables)
		
		viewStore.publisher
			.shouldIncludeScreenshots
			.removeDuplicates()
			.sink { [weak self] incoming in
				self?.setNeedsUpdateDataSourceFiltering()
			}
			.store(in: &cancellables)
	}
	
	// MARK: - Helpers
	
	private func setNeedsUpdateDataSourceFiltering() {
		guard viewStore.permissionState == .allowed else { return }
		
		if !hasRegisteredAsObserver && viewStore.permissionState == .allowed {
			PHPhotoLibrary.shared().register(self); #warning("App hang reported here...")
			hasRegisteredAsObserver = true
		}

		let options = PHFetchOptions()
		options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
		
		switch viewStore.galleryFilter {
		case .all:
			assetsParsingQueue.async {
				if self.viewStore.shouldIncludeScreenshots {
					options.predicate = .init(
						format: "(mediaType = %d)",
						PHAssetMediaType.image.rawValue
					)
				}
				else {
					options.predicate = .init(
						format: "(mediaType = %d) && (NOT (mediaSubtype & %d) != 0)",
						PHAssetMediaType.image.rawValue,
						PHAssetMediaSubtype.photoScreenshot.rawValue
					)
				}
				
				let loaded = PHAsset.fetchAssets(with: options)
				DispatchQueue.main.async {
					self.assets = loaded
					self.assetsDidUpdateNotifierSubject.send()
				}
			}
			
		case .favourites:
			assetsParsingQueue.async {
				if self.viewStore.shouldIncludeScreenshots {
					options.predicate = .init(
						format: "(mediaType = %d && favorite == true)",
						PHAssetMediaType.image.rawValue
					)
				}
				else {
					options.predicate = .init(
						format: "(mediaType = %d && favorite == true) && (NOT (mediaSubtype & %d) != 0)",
						PHAssetMediaType.image.rawValue,
						PHAssetMediaSubtype.photoScreenshot.rawValue
					)
				}
				
				let loaded = PHAsset.fetchAssets(with: options)
				DispatchQueue.main.async {
					self.assets = loaded
					self.assetsDidUpdateNotifierSubject.send()
				}
			}
			
		case .selfies:
			assetsParsingQueue.async {
				options.predicate = .init(
					format: "(mediaType = %d)",
					PHAssetMediaType.image.rawValue
				)
				
				guard
					let selfieAlbum = PHAssetCollection.fetchAssetCollections(
						with: .smartAlbum,
						subtype: .smartAlbumSelfPortraits,
						options: nil
					).firstObject
				else {
					self.assets = .init()
					return
				}
				
				let loaded = PHAsset.fetchAssets(in: selfieAlbum, options: options)
				DispatchQueue.main.async {
					self.assets = loaded
					self.assetsDidUpdateNotifierSubject.send()
				}
			}
		}
	}
	
	// MARK: - PHPhotoLibraryChangeObserver
	
	func photoLibraryDidChange(_ changeInstance: PHChange) {
		DispatchQueue.main.sync {
			guard let changes = changeInstance.changeDetails(for: self.assets) else { return }
			self.assets = changes.fetchResultAfterChanges
			self.assetsDidUpdateNotifierSubject.send()
		}
	}
	
}
