import Foundation

public protocol AutoNullable {}
public protocol AutoMockable {}
public protocol AutomaticSettings: Codable, Equatable {}
public protocol AutomaticSettingsEnum: RawRepresentable, Codable, Equatable, CaseIterable {}
