import Foundation

public enum TemperaturePreset: String, Identifiable, CaseIterable {
	public var id: Self { self }
	
	case cool
	case neutral
	case warm
}
