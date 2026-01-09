import SwiftUI
import UserNotifications
import Presentation
import Data
import Domain
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
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        
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
extension AppDelegate: UNUserNotificationCenterDelegate {
    // 앱이 foreground에 있을 때 푸시 알림 수신
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        let roomId = userInfo["room_id"] as? String
        
        let wrappedCompletion = SendableNotificationHandler(handler: completionHandler)
        
        Task {
            let activeChatRoomId = await ActiveChatRoomManager.shared.getActiveChatRoom()
            
            let options: UNNotificationPresentationOptions = (activeChatRoomId == roomId) ? [] : [.banner, .sound, .badge]
            
            await MainActor.run {
                wrappedCompletion(options)
            }
        }
    }

    // 사용자가 알림을 탭했을 때
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let roomId = userInfo["room_id"] as? String
        let date = response.notification.date
        let wrappedCompletion = SendableVoidHandler(handler: completionHandler)
        
        Task { @MainActor in
            if let roomId {
                NotificationCenter.default.post(
                    name: .navigateToChat,
                    object: nil,
                    userInfo: [
                        "roomId": roomId,
                        "date": date
                    ]
                )
            }
            wrappedCompletion()
        }
    }
}

// completionHandler를 감싸서 Sendable로 위장시키는 래퍼 구조체
private struct SendableNotificationHandler: @unchecked Sendable {
    let handler: (UNNotificationPresentationOptions) -> Void
    
    func callAsFunction(_ options: UNNotificationPresentationOptions) {
        handler(options)
    }
}

private struct SendableVoidHandler: @unchecked Sendable {
    let handler: () -> Void
    
    func callAsFunction() {
        handler()
    }
}
