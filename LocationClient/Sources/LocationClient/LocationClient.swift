import AsyncLocationKit
import Combine
import ComposableArchitecture
import CoreLocation
import Preferences
import UIKit

public protocol LocationClient {
	var lastKnownLocation: CLLocation? { get }
	var permission: CLAuthorizationStatus { get }
	
	func setNeedsUpdateLocation()
	func requestPermission(with permissionType: LocationPermission) async -> CLAuthorizationStatus
}

public final class LiveLocationClient: NSObject, LocationClient, CLLocationManagerDelegate {
	
	// MARK: - Properties
	
	public var lastKnownLocation: CLLocation? { manager.location }
	public var permission: CLAuthorizationStatus { manager.authorizationStatus }

	@Dependency(\.preferencesClient) var preferencesClient
	
	// MARK: - Properties (Private)
	
	private lazy var manager: CLLocationManager = {
		let created = CLLocationManager()
		created.delegate = self
		return created
	}()
	private let asyncLocationManager = AsyncLocationManager(desiredAccuracy: .bestAccuracy)
	
	// MARK: - Init
	
	public override init() {
		super.init()
		
		NotificationCenter.default.addObserver(
			forName: UIApplication.willEnterForegroundNotification,
			object: nil,
			queue: .main
		) { [weak self] _ in
			guard
				let self = self,
				self.preferencesClient.shouldEmbedLocationDataInCaptures,
				self.manager.authorizationStatus == .authorizedWhenInUse
			else { return }
			
			self.manager.requestLocation()
		}
	}
	
	// MARK: - LocationClient
	
	public func setNeedsUpdateLocation() {
		guard manager.authorizationStatus == .authorizedWhenInUse else { return }
		manager.requestLocation()
	}
	
	public func requestPermission(with permissionType: LocationPermission) async -> CLAuthorizationStatus {
			return await self.asyncLocationManager.requestPermission(with: .whenInUsage)
	}

	// MARK: - CLLocationManagerDelegate
	
	public func locationManager(
		_ manager: CLLocationManager,
		didUpdateLocations locations: [CLLocation]
	) { }
	
	public func locationManager(
		_ manager: CLLocationManager,
		didFailWithError error: Error
	) { }
}

private enum LocationClientKey: DependencyKey {
	static let liveValue: LocationClient = LiveLocationClient()
}

public extension DependencyValues {
	var locationClient: LocationClient {
		get { self[LocationClientKey.self] }
		set { self[LocationClientKey.self] = newValue }
	}
}
