import ComposableArchitecture
import Sentry
import SwiftUI

@main
struct apertureApp: App {

	@UIApplicationDelegateAdaptor
	private var delegate: AppDelegate
	private let store = Store(initialState: AppFeature.State(), reducer: AppFeature())

	var body: some Scene {
		WindowGroup {
			AppView(store)
				.preferredColorScheme(.dark)
				.edgesIgnoringSafeArea(.all)
				.registerCustomFonts()
		}
	}

	public init() {
		#if !DEBUG
		SentrySDK.start { options in
			options.dsn = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
			options.tracesSampleRate = 1.0
			options.enableAppHangTracking = false
		}
		#endif
	}
	
}
