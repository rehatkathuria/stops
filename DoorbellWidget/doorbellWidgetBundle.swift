import CameraFeature
import SwiftUI
import WidgetKit

@main
struct doorbellWidgetBundle: WidgetBundle {
	var body: some Widget {
		if #available(iOS 18, *) {
			LockedWidgetControl()
		}
	}
}

@available(iOS 18, *)
struct LockedWidgetControl: ControlWidget {
	var body: some ControlWidgetConfiguration {
		StaticControlConfiguration(
			kind: "com.eff.corp.aperture.doorbell.widget.control"
		) {
			ControlWidgetButton(action: AppCaptureIntent()) {
				Label("Launch App", systemImage: "camera.shutter.button")
			}
		}
		.displayName("Launch Camera")
		.description("Launch the camera for Stops")
	}
}
