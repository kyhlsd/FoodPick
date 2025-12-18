//
//  DefaultTokenRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 12/19/25.
//

import Foundation
import Domain

public final class DefaultTokenRepositoryImpl: TokenRepository {
    private let keychainManager: KeychainManager

    private enum Keys {
        static let accessToken = "access_token"
        static let refreshToken = "refresh_token"
    }

    public init(keychainManager: KeychainManager = .shared) {
        self.keychainManager = keychainManager
    }

    public func saveAccessToken(_ token: String) async throws {
        try await keychainManager.save(key: Keys.accessToken, value: token)
    }

    public func saveRefreshToken(_ token: String) async throws {
        try await keychainManager.save(key: Keys.refreshToken, value: token)
    }

    public func getAccessToken() async throws -> String {
        try await keychainManager.load(key: Keys.accessToken)
    }

    public func getRefreshToken() async throws -> String {
        try await keychainManager.load(key: Keys.refreshToken)
    }

    public func deleteTokens() async throws {
        try await keychainManager.delete(key: Keys.accessToken)
        try await keychainManager.delete(key: Keys.refreshToken)
    }
}
