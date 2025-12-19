//
//  DefaultDeviceTokenRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 12/19/25.
//

import UIKit
import UserNotifications
import Domain

public actor DefaultDeviceTokenRepositoryImpl: DeviceTokenRepository {
    public static let shared = DefaultDeviceTokenRepositoryImpl()

    private var deviceToken: String?
    private var continuation: CheckedContinuation<String, Error>?

    private init() {}

    public func getDeviceToken() async throws -> String {
        // 이미 토큰이 있으면 반환
        if let token = deviceToken {
            return token
        }

        // 푸시 알림 권한 요청
        let center = UNUserNotificationCenter.current()
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])

        guard granted else {
            throw DeviceTokenError.permissionDenied
        }

        // 메인 스레드에서 APNs 등록
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            Task { @MainActor in
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    // AppDelegate에서 토큰을 받았을 때 호출
    public func setDeviceToken(_ token: String) {
        deviceToken = token
        continuation?.resume(returning: token)
        continuation = nil
    }

    // AppDelegate에서 토큰 등록 실패 시 호출
    public func setDeviceTokenError(_ error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }

    // 저장된 토큰을 반환
    public func getCurrentToken() -> String? {
        return deviceToken
    }
}
