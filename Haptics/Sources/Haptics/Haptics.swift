import AVFoundation
import ComposableArchitecture
import struct CoreGraphics.CGFloat
import CoreHaptics

private let queue = DispatchQueue(
	label: "com.eff.corp.haptic.client.thread",
	qos: .userInteractive
)

#if !os(macOS)
import UIKit
#endif

public struct HapticClient {
	static var areHapticsEnabled = false
	
	public var areHapticsEnabled: (Bool) -> EffectTask<Never>
	public var prepare: () -> EffectTask<Never>
	public var selectionChanged: () -> EffectTask<Never>
	public var success: () -> EffectTask<Never>
	public var error: () -> EffectTask<Never>
	public var impact: () -> EffectTask<Never>
	public var rigidImpact: (CGFloat) -> EffectTask<Never>
}

public extension HapticClient {
	static var live: Self {
		let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
		let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
		let impactFeedbackGenerator = UIImpactFeedbackGenerator()
		let rigidImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)
		
		return .init(
			areHapticsEnabled: { areEnabled in
					.fireAndForget {
						HapticClient.areHapticsEnabled = areEnabled
					}
			},
			prepare: {
				.fireAndForget {
					guard HapticClient.areHapticsEnabled else { return }
					queue.async {
						selectionFeedbackGenerator.prepare()
						notificationFeedbackGenerator.prepare()
						impactFeedbackGenerator.prepare()
						rigidImpactFeedbackGenerator.prepare()
					}
				}
			},
			selectionChanged: {
				.fireAndForget {
					guard HapticClient.areHapticsEnabled else { return }
					queue.async {
						selectionFeedbackGenerator.selectionChanged()
					}
				}
			},
			success: {
				.fireAndForget {
					guard HapticClient.areHapticsEnabled else { return }
					queue.async {
						notificationFeedbackGenerator.notificationOccurred(.success)
					}
				}
			},
			error: {
				.fireAndForget {
					guard HapticClient.areHapticsEnabled else { return }
					queue.async {
						notificationFeedbackGenerator.notificationOccurred(.error)
					}
				}
			},
			impact: {
				.fireAndForget {
					guard HapticClient.areHapticsEnabled else { return }
					queue.async {
						impactFeedbackGenerator.impactOccurred()
					}
				}
			},
			rigidImpact: { intensity in
					.fireAndForget {
						guard HapticClient.areHapticsEnabled else { return }
						queue.async {
							rigidImpactFeedbackGenerator.impactOccurred(
								intensity: intensity
							)
						}
					}
			}
		)
	}
}

public extension HapticClient {
	static var test: HapticClient {
		return .init(
			areHapticsEnabled: { _ in .none	},
			prepare: { .none },
			selectionChanged: { .none },
			success: { .none },
			error: { .none },
			impact: { .none },
			rigidImpact: { _ in .none }
		)
	}
}

private enum HapticClientKey: DependencyKey {
	static let liveValue: HapticClient = HapticClient.live
	static var testValue: HapticClient = HapticClient.test
}

public extension DependencyValues {
	var hapticClient: HapticClient {
		get { self[HapticClientKey.self] }
		set { self[HapticClientKey.self] = newValue }
	}
}
