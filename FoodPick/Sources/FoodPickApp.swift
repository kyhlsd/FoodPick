import SwiftUI
import Presentation
import Data
import ComposableArchitecture

@main
struct FoodPickApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        FontRegistration.registerFonts()
        KakaoSDKManager.initialize()
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
            .onOpenURL { url in
                _ = KakaoSDKManager.handleOpenURL(url)
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
            await DeviceTokenRepositoryImpl.shared.setDeviceToken(tokenString)
        }
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        Task {
            await DeviceTokenRepositoryImpl.shared.setDeviceTokenError(error)
        }
    }
}
