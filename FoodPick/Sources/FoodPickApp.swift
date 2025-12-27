import SwiftUI
import Presentation
import Data
import Core
import iamport_ios

@main
struct FoodPickApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        let configuration = DefaultAppConfiguration()
        APIInfos.configure(with: configuration)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
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
            await DefaultDeviceTokenRepositoryImpl.shared.setDeviceToken(tokenString)
        }
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        Task {
            await DefaultDeviceTokenRepositoryImpl.shared.setDeviceTokenError(error)
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        Iamport.shared.receivedURL(url)
        return true
    }
}
