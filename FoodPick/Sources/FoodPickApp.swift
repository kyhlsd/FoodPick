import SwiftUI
import Presentation
import ComposableArchitecture
import Core

@main
struct FoodPickApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        FontRegistration.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                LoginView(
                    store: Store(initialState: LoginFeature.State()) {
                        LoginFeature()
                    }
                )
            }
        }
    }
}

// MARK: - AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        Task {
            await DeviceTokenProvider.shared.setDeviceToken(tokenString)
        }
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        Task {
            await DeviceTokenProvider.shared.setDeviceTokenError(error)
        }
    }
}
