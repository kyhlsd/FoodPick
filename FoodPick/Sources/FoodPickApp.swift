import SwiftUI
import UserNotifications
import Presentation
import Data
import Core
import iamport_ios
import FirebaseCore
import FirebaseMessaging

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
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        Messaging.messaging().delegate = self

        UNUserNotificationCenter.current().delegate = self

        // 권한과 무관하게 APNS 등록
        application.registerForRemoteNotifications()

        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
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

// MARK: - MessagingDelegate
@MainActor
extension AppDelegate: MessagingDelegate {
    // FCM 토큰이 갱신되었을 때 호출
    nonisolated func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken else { return }
        Task {
            await DefaultDeviceTokenRepositoryImpl.shared.setDeviceToken(fcmToken)

            do {
                let userRepository = DefaultUserRepositoryImpl()
                try await userRepository.updateDeviceToken(deviceToken: fcmToken)
            } catch {
                await DefaultDeviceTokenRepositoryImpl.shared.setDeviceTokenError(error)
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
@MainActor
extension AppDelegate: UNUserNotificationCenterDelegate {
    // 앱이 foreground에 있을 때 푸시 알림 수신
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        completionHandler([.banner, .sound, .badge])
    }

    // 사용자가 알림을 탭했을 때
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        // TODO: 알림 타입에 따라 특정 화면으로 이동 처리
        // 예: 채팅 알림이면 해당 채팅방으로 이동
        // if let roomId = userInfo["roomId"] as? String {
        //     // 채팅방으로 이동
        // }

        completionHandler()
    }
}
