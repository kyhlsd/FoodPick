//
//  DefaultDeviceTokenRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 12/19/25.
//

import UIKit
import UserNotifications
import Domain
import Core
import FirebaseMessaging

public actor DefaultDeviceTokenRepositoryImpl: DeviceTokenRepository {
    public static let shared = DefaultDeviceTokenRepositoryImpl()

    private var deviceToken: String?
    private var continuation: AsyncStream<String>.Continuation?
    private let tokenStream: AsyncStream<String>

    private init() {
        var streamContinuation: AsyncStream<String>.Continuation?
        self.tokenStream = AsyncStream { continuation in
            streamContinuation = continuation
        }
        self.continuation = streamContinuation
    }

    public func getDeviceToken() async throws -> String {
        // 이미 토큰이 있으면 반환
        if let token = deviceToken {
            return token
        }
        
        let fetchedToken = try await Messaging.messaging().token()
        guard !fetchedToken.isEmpty else {
            throw DeviceTokenError.tokenNotAvailable
        }

        await self.setDeviceToken(fetchedToken)
        return fetchedToken
    }

    // MessagingDelegate에서 FCM 토큰을 받았을 때 호출
    public func setDeviceToken(_ token: String) async {
        deviceToken = token
        continuation?.yield(token)
    }

    // AppDelegate에서 토큰 등록 실패 시 호출
    public func setDeviceTokenError(_ error: Error) async {
        await MainActor.run {
            NotificationCenter.default.post(
                name: NSNotification.Name.deviceTokenError,
                object: nil,
                userInfo: ["error": error]
            )
        }
    }

    // 저장된 토큰을 반환
    public func getCurrentToken() async -> String? {
        return deviceToken
    }

    // FCM 토큰 변경을 감지하는 스트림
    nonisolated public func tokenUpdates() -> AsyncStream<String> {
        return tokenStream
    }
}
