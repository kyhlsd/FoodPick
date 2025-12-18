//
//  DeviceTokenProvider.swift
//  Core
//
//  Created by 김영훈 on 12/19/25.
//

import UIKit
import UserNotifications

public actor DeviceTokenProvider {
    public static let shared = DeviceTokenProvider()

    private var deviceToken: String?
    private var continuation: CheckedContinuation<String, Error>?

    private init() {}

    // 디바이스 토큰을 가져옵니다. 토큰이 없으면 푸시 권한을 요청하고 등록합니다.
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

public enum DeviceTokenError: LocalizedError {
    case permissionDenied
    case registrationFailed

    public var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "푸시 알림 권한이 거부되었습니다."
        case .registrationFailed:
            return "디바이스 토큰 등록에 실패했습니다."
        }
    }
}
