import Combine
import ComposableArchitecture
import Convenience
import PermissionsClient
import Photos
import Preferences
import Shared
import SwiftUI
import UIKit

final class AssetViewController:
UICollectionViewController,
UICollectionViewDataSourcePrefetching,
UICollectionViewDelegateFlowLayout,
AssetTransitioning
{
	var layoutStyle: AssetLayoutStyle
	let queue: DispatchQueue

	private let player = AVPlayer()
	
	var assetSize: CGSize = CGSize.zero
	var transitioningAsset: GalleryDisplayable? {
		willSet(value) {
			if let value { viewStore.send(.setFocusedDisplayable(value)) }
		}
	}
	var sizeTransitionIndexPath: IndexPath?
	var shutterStyle: ShutterStyle
	
	let store: StoreOf<GalleryFeature>
	let viewStore: ViewStoreOf<GalleryFeature>
	
	private var cancellables = Set<AnyCancellable>()
	
	private var galleryFiltering: GalleryFilter
	private var permissionState: PermissionState?
	private var shouldDisablePresentation = false
	private var flowLayout: UICollectionViewFlowLayout {
		collectionViewLayout as! UICollectionViewFlowLayout
	}
	private let reuseIdentifier = "com.eff.corp.aperture.cell"
	
	// MARK: Lifecycle
	
	init(
		layoutStyle: AssetLayoutStyle,
		shutterStyle: ShutterStyle,
		store: StoreOf<GalleryFeature>
	) {
		self.layoutStyle = layoutStyle
		self.store = store
		self.viewStore = .init(store)
		self.shutterStyle = shutterStyle
		self.galleryFiltering = self.viewStore.galleryFilter
		self.permissionState = self.viewStore.permissionState
		
		queue = DispatchQueue(
			label: "com.photo.prewarm",
			qos: .default,
			attributes: [.concurrent],
			autoreleaseFrequency: .inherit,
			target: nil
		)
		
		super.init(collectionViewLayout: UICollectionViewFlowLayout())
		
		if assetsHolder == nil { assetsHolder = AssetsHolder(store: store) }
		
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.alwaysBounceVertical = layoutStyle == .grid
		collectionView.alwaysBounceHorizontal = layoutStyle == .detailed
		collectionView.clipsToBounds = false
		collectionView.layer.masksToBounds = false
		
		viewStore.publisher
			.map(\.galleryFilter)
			.removeDuplicates()
			.sink { [weak self] newValue in
				guard
					let self = self,
					self.galleryFiltering != newValue
				else { return }
				
				self.galleryFiltering = newValue
				self.collectionView.setContentOffset(.zero, animated: false)
				self.collectionView.reloadData()
			}
			.store(in: &cancellables)
		
		assetsHolder
			.assetsDidUpdateNotifier
			.receive(on: DispatchQueue.main)
			.sink { [weak self] _ in
				self?.collectionView.reloadData()
				self?.setNeedsUpdateFocusedIndexPath()
			}
			.store(in: &cancellables)
	}
	
	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) { fatalError() }
	
	// MARK: - View Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor.clear
		view.clipsToBounds = true
		
		if let collectionView = self.collectionView {
			collectionView.register(AssetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
			collectionView.isPrefetchingEnabled = true
			collectionView.prefetchDataSource = self
			collectionView.backgroundColor = UIColor.clear
		}
	}
	
	override func viewWillAppear(
		_ animated: Bool
	) {
		super.viewWillAppear(animated)
		
		recalculateItemSize(inBoundingSize: self.view.bounds.size)
		
		switch layoutStyle {
		case .grid: break
		case .detailed:
			self.collectionView.contentInsetAdjustmentBehavior = .never
			self.collectionView?.isPagingEnabled = true
		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		recalculateItemSize(inBoundingSize: self.view.bounds.size)
		
		switch layoutStyle {
		case .grid: break
		case .detailed:
			self.collectionView.contentInsetAdjustmentBehavior = .never
			self.collectionView?.isPagingEnabled = true
		}
	}
	
	override func viewWillTransition(
		to size: CGSize,
		with coordinator: UIViewControllerTransitionCoordinator
	) {
		recalculateItemSize(inBoundingSize: size)
		if view.window == nil {
			view.frame = CGRect(origin: view.frame.origin, size: size)
			view.layoutIfNeeded()
		} else {
			let indexPath = self.collectionView?.indexPathsForVisibleItems.last
			coordinator.animate(alongsideTransition: { ctx in
				self.collectionView?.layoutIfNeeded()
			}, completion: { _ in
				if self.layoutStyle == .detailed, let indexPath = indexPath {
					self.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
				}
			})
		}
		
		super.viewWillTransition(to: size, with: coordinator)
	}
	
	// MARK: - View Helpers
	
	private func recalculateItemSize(
		inBoundingSize size: CGSize
	) {
		layoutStyle.recalculate(layout: flowLayout, inBoundingSize: size)
		let itemSize = flowLayout.itemSize
		let scale = UIScreen.main.scale
		assetSize = CGSize(width: itemSize.width * scale, height: itemSize.height * scale);
	}
	
	// MARK: - Presentation
	
	private func present(
		_ indexPath: IndexPath
	) {
		shouldDisablePresentation = true
		
		let assetViewController = AssetViewController(
			layoutStyle: .detailed,
			shutterStyle: shutterStyle,
			store: store
		)
		assetViewController.flowLayout.itemSize = view.bounds.size
		assetViewController.transitioningAsset = displayableForIndexPath(indexPath)
		navigationController?.pushViewController(assetViewController, animated: true)
		viewStore.send(.setIsPresentingDetailedImageView(true))
	}
	
	// MARK: UICollectionViewDataSource
	
	override func collectionView(
		_ collectionView: UICollectionView,
		numberOfItemsInSection section: Int
	) -> Int {
		switch galleryFiltering {
		case .all: return assetsHolder.assets.count
		case .favourites: return assetsHolder.assets.count
		case .selfies: return assetsHolder.assets.count
		}
	}
	
	override func collectionView(
		_ collectionView: UICollectionView,
		cellForItemAt indexPath: IndexPath
	) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! AssetCell
		
		if layoutStyle == .detailed {
			cell.imageView.contentMode = .scaleAspectFit;
		}
		
		cell.layoutStyle = layoutStyle
		cell.shouldAllowLongPress = indexPath.section == 0 && layoutStyle == .detailed
		
		let displayable = displayableForIndexPath(indexPath)
		
		cell.assetIdentifier = displayable.localIdentifier
		
		let options = PHImageRequestOptions()
		options.deliveryMode = .opportunistic
		options.isNetworkAccessAllowed = true
		
		imageManager.requestImage(
			for: displayable,
			targetSize: self.assetSize,
			contentMode: .aspectFit,
			options: options
		) { (result, info) in
			guard
				cell.assetIdentifier == displayable.localIdentifier
			else { return }
			cell.imageView.image = result
		}
		
		if displayable.mediaType == .video, layoutStyle == .detailed {
			let videoOptions = PHVideoRequestOptions()
			videoOptions.deliveryMode = .automatic
			videoOptions.isNetworkAccessAllowed = true
			imageManager.requestAVAsset(
				forVideo: displayable,
				options: videoOptions
			) { result, audioMix, info in
				guard
					cell.assetIdentifier == displayable.localIdentifier
				else { return }
				cell.asset = result
			}
		}
		
		return cell
	}
	
	override func numberOfSections(
		in collectionView: UICollectionView
	) -> Int { 1 }
	
	// MARK: UICollectionViewDelegate
	
	override func collectionView(
		_ collectionView: UICollectionView,
		didSelectItemAt indexPath: IndexPath
	) {
		guard layoutStyle == .grid else { return }
		
		guard
			shouldDisablePresentation == false
		else {
			return
		}
		
		viewStore.send(.didRequestPresentationHaptic)
		present(indexPath)
	}
	
	override func collectionView(
		_ collectionView: UICollectionView,
		targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint
	) -> CGPoint {
		guard
			layoutStyle == .detailed,
			let indexPath = collectionView.indexPathsForVisibleItems.last,
			let layoutAttributes = flowLayout.layoutAttributesForItem(at: indexPath)
		else {
			return proposedContentOffset
		}
		
		return CGPoint(
			x: layoutAttributes.center.x - (layoutAttributes.size.width / 2.0) - (flowLayout.minimumLineSpacing / 2.0),
			y: 0
		)
	}
	
	// MARK: - UICollectionViewDelegateFlowLayout
	
	func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		insetForSectionAt section: Int
	) -> UIEdgeInsets {
		guard layoutStyle == .grid else { return .zero }
		
		return .init(
			top: 15,
			left: 15,
			bottom: 15,
			right: 15
		)
	}
	
	// MARK: UICollectionViewDataSourcePrefetching
	
	func collectionView(
		_ collectionView: UICollectionView,
		prefetchItemsAt indexPaths: [IndexPath]
	) {
		let assets = assetsForIndexPaths(indexPaths)
		queue.async {
			imageManager.startCachingImages(
				for: assets,
				targetSize: self.assetSize,
				contentMode: .aspectFill,
				options: nil
			)
		}
	}
	
	func collectionView(
		_ collectionView: UICollectionView,
		cancelPrefetchingForItemsAt indexPaths: [IndexPath]
	) {
		let assets = assetsForIndexPaths(indexPaths)
		queue.async {
			imageManager.stopCachingImages(
				for: assets,
				targetSize: self.assetSize,
				contentMode: .aspectFill,
				options: nil
			)
		}
	}
	
	// MARK: - UIScrollViewDelegate
	
	override func scrollViewDidEndDecelerating(
		_ scrollView: UIScrollView
	) {
		setNeedsUpdateFocusedIndexPath()
	}
	
	override func scrollViewDidEndScrollingAnimation(
		_ scrollView: UIScrollView
	) {
		setNeedsUpdateFocusedIndexPath()
	}
	
	// MARK: - AssetTransitioning
	
	func itemsForTransition(
		context: UIViewControllerContextTransitioning
	) -> Array<AssetTransitionItem> {
		guard let collectionView = self.collectionView else { return [] }
		
		var indexPaths = collectionView.indexPathsForVisibleItems
		if context.isInteractive {
			if let indexPath = collectionView.indexPathForItem(at: collectionView.panGestureRecognizer.location(in: collectionView)) {
				indexPaths = [indexPath]
			}
		}
		
		return indexPaths
			.compactMap({ (indexPath: IndexPath) -> AssetTransitionItem? in
				guard
					let cell = collectionView.cellForItem(at: indexPath) as? AssetCell
				else { return nil }
				
				let displayable = self.displayableForIndexPath(indexPath)
				let initialFrame: CGRect
				
				switch self.layoutStyle {
				case .detailed:
					let boundingRect = cell.imageView.convert(
						cell.imageView.bounds.offsetBy(dx: -2, dy: -(shutterStyle.bottomBarTransitionOffset + bottomSafeArea)),
						to: nil
					)
					let aspectRatio = CGSize(width: displayable.pixelWidth, height: displayable.pixelHeight)
					initialFrame = AVMakeRect(aspectRatio: aspectRatio, insideRect: boundingRect)
				case .grid:
					initialFrame = cell.convert(cell.bounds, to: nil)
				}
				
				guard let image = cell.imageView.image else { return nil }
				
				return AssetTransitionItem(
					initialFrame: initialFrame,
					image: image,
					indexPath: indexPath,
					object: displayable
				)
			})
	}
	
	func targetFrame(
		transitionItem item: AssetTransitionItem
	) -> CGRect? {
		guard let collectionView = self.collectionView else { return nil }
		
		switch self.layoutStyle {
		case .detailed:
			if item.object.localIdentifier == self.transitioningAsset?.localIdentifier {
				let boundingRect = self.view.window!.convert(self.view.bounds, to: nil)
				let aspectRatio = CGSize(width: item.object.pixelWidth, height: item.object.pixelHeight)
				return AVMakeRect(
					aspectRatio: aspectRatio,
					insideRect: .init(
						x: boundingRect.width.half - boundingRect.width.eightTenths.half,
						y: boundingRect.height.half - boundingRect.height.eightTenths.half,
						width: boundingRect.width.eightTenths,
						height: boundingRect.height.eightTenths
					)
				)
			}
		case .grid:
			if !collectionView.indexPathsForVisibleItems.contains(item.indexPath) {
				collectionView.scrollToItem(at: item.indexPath, at: .centeredVertically, animated: false)
				collectionView.layoutIfNeeded()
			}
			
			if let cell = collectionView.cellForItem(at: item.indexPath) as? AssetCell {
				if cell.assetIdentifier == item.object.localIdentifier {
					return cell.convert(cell.bounds,to: collectionView.superview)
				}
			}
		}
		
		return nil
	}
	
	func willTransition(
		fromController: UIViewController,
		toController: UIViewController,
		items: Array<AssetTransitionItem>
	) {
		guard let collectionView = self.collectionView else { return }
		
		switch self.layoutStyle {
		case .detailed:
			collectionView.alpha = 0.0
			collectionView.panGestureRecognizer.isEnabled = false
			if self == toController {
				if let asset = items.last?.object {
					let indexPath = IndexPath(row: indexForDisplayable(asset), section: 0)
					collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
				}
			}
		case .grid:
			let options = PHImageRequestOptions()
			options.deliveryMode = .opportunistic
			options.isNetworkAccessAllowed = true
			
			for item in items {
				collectionView.cellForItem(at: item.indexPath)?.alpha = 0.0
				
				// Update the image resolution
				if self == fromController {
					imageManager.requestImage(
						for: item.object,
						targetSize: item.targetFrame!.size,
						contentMode: .aspectFit,
						options: options,
						resultHandler: { [weak item] (result, _) in
							if let image = result { item?.image = image }
						}
					)
				}
			}
		}
	}
	
	func didTransition(
		fromController: UIViewController,
		toController: UIViewController,
		items: Array<AssetTransitionItem>
	) {
		guard let collectionView = self.collectionView else { return }
		
		switch self.layoutStyle {
		case .detailed:
			collectionView.alpha = 1.0
			collectionView.panGestureRecognizer.isEnabled = true
		case .grid:
			for item in items {
				collectionView.cellForItem(at: item.indexPath)?.alpha = 1.0
			}
		}
		
		if let to = toController as? AssetViewController, to.layoutStyle == .grid {
			to.shouldDisablePresentation = false
		}
	}
	
	// MARK: - Index Path Updating
	
	private func setNeedsUpdateFocusedIndexPath() {
		guard
			let displayable = currentFocusedDisplayable()
		else { return }
		viewStore.send(.setFocusedDisplayable(displayable))
		
		guard
			displayable.mediaType == .video,
			let indexPath = findCenterIndex(),
			let cell = collectionView.cellForItem(at: indexPath) as? AssetCell,
			let result = cell.asset
		else { return }
		
		cell.playerLayer.player = player
		player.replaceCurrentItem(with: .init(asset: result))
		player.play()
	}
	
	private func findCenterIndex() -> IndexPath? {
		let center = self.view.convert(self.collectionView.center, to: self.collectionView)
		return collectionView?.indexPathForItem(at: center)
	}
	
	private func assetsForIndexPaths(
		_ indexPaths: [IndexPath]
	) -> [PHAsset] {
		switch galleryFiltering {
		case .all: return indexPaths.map { assetsHolder.assets.object(at: $0.item) }
		case .favourites: return indexPaths.map { assetsHolder.assets.object(at: $0.item) }
		case .selfies: return indexPaths.map { assetsHolder.assets.object(at: $0.item) }
		}
	}
	
	private func displayableForIndexPath(
		_ indexPath: IndexPath
	) -> GalleryDisplayable {
		switch galleryFiltering {
		case .all: return assetsHolder.assets.object(at: indexPath.row)
		case .favourites: return assetsHolder.assets.object(at: indexPath.row)
		case .selfies: return assetsHolder.assets.object(at: indexPath.row)
		}
	}
	
	private func currentFocusedDisplayable() -> GalleryDisplayable? {
		guard
			layoutStyle == .detailed,
			let indexPath = findCenterIndex()
		else { return nil }
		
		return displayableForIndexPath(indexPath)
	}
	
	private func indexForDisplayable(
		_ asset: GalleryDisplayable
	) -> Int {
		switch galleryFiltering {
		case .all: return assetsHolder.assets.index(of: asset)
		case .favourites: return assetsHolder.assets.index(of: asset)
		case .selfies: return assetsHolder.assets.index(of: asset)
		}
	}
}

extension PHAsset: Identifiable { }
