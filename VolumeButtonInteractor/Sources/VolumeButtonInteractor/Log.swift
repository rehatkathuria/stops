import Foundation
import os.log

extension OSLog {
	private static let subsystem = "com.eff.corp.aperture.VolumeButtonHandler"
	private static let category = "audio_session"
	static let audioSession = OSLog(subsystem: OSLog.subsystem, category: OSLog.category)
}

func logEvent(_ message: String, _ category: OSLog) {
	os_log("%{public}@", log: category, type: .info, message)
}
