//
//  DefaultTokenRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 12/19/25.
//

import Foundation
import Security
import Domain
import Alamofire

public final class DefaultTokenRepositoryImpl: TokenRepository {
    private let refreshSession: Session

    private enum Keys {
        static let accessToken = "access_token"
        static let refreshToken = "refresh_token"
    }

    public init() {
        self.refreshSession = Session()
    }

    public func saveAccessToken(_ token: String) async throws {
        try saveToKeychain(key: Keys.accessToken, value: token)
    }

    public func saveRefreshToken(_ token: String) async throws {
        try saveToKeychain(key: Keys.refreshToken, value: token)
    }

    public func getAccessToken() async throws -> String {
        try loadFromKeychain(key: Keys.accessToken)
    }

    public func getRefreshToken() async throws -> String {
        try loadFromKeychain(key: Keys.refreshToken)
    }

    public func deleteTokens() async throws {
        try deleteFromKeychain(key: Keys.accessToken)
        try deleteFromKeychain(key: Keys.refreshToken)
    }

    public func refreshTokens() async throws {
        let refreshToken = try await getRefreshToken()

        return try await withCheckedThrowingContinuation { continuation in
            do {
                var urlRequest = try AuthRouter.refresh.asURLRequest()
                urlRequest.setValue(refreshToken, forHTTPHeaderField: "RefreshToken")

                refreshSession.request(urlRequest)
                    .validate()
                    .responseDecodable(of: TokenResponse.self) { [weak self] response in
                        guard let self else {
                            continuation.resume(throwing: APIError.unknown)
                            return
                        }

                        switch response.result {
                        case .success(let tokenResponse):
                            Task {
                                do {
                                    try await self.saveAccessToken(tokenResponse.accessToken)
                                    try await self.saveRefreshToken(tokenResponse.refreshToken)
                                    continuation.resume()
                                } catch {
                                    continuation.resume(throwing: error)
                                }
                            }
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    // MARK: - Keychain Operations
    private func saveToKeychain(key: String, value: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.encodingFailed
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    private func loadFromKeychain(key: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            throw KeychainError.loadFailed(status)
        }

        guard let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            throw KeychainError.decodingFailed
        }

        return value
    }

    private func deleteFromKeychain(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }
}

// MARK: - KeychainError
enum KeychainError: LocalizedError {
    case encodingFailed
    case decodingFailed
    case saveFailed(OSStatus)
    case loadFailed(OSStatus)
    case deleteFailed(OSStatus)

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "데이터 인코딩에 실패했습니다."
        case .decodingFailed:
            return "데이터 디코딩에 실패했습니다."
        case .saveFailed(let status):
            return "Keychain 저장에 실패했습니다. (Status: \(status))"
        case .loadFailed(let status):
            return "Keychain 로드에 실패했습니다. (Status: \(status))"
        case .deleteFailed(let status):
            return "Keychain 삭제에 실패했습니다. (Status: \(status))"
        }
    }
}
