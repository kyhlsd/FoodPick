//
//  DeviceTokenProvider.swift
//  Domain
//
//  Created by 김영훈 on 12/19/25.
//

import Foundation

public protocol DeviceTokenProvider: Sendable {
    func getDeviceToken() async throws -> String
    func setDeviceToken(_ token: String) async
    func setDeviceTokenError(_ error: Error) async
    func getCurrentToken() async -> String?
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
