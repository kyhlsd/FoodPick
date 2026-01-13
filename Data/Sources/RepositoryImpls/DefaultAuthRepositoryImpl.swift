//
//  DefaultAuthRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 12/19/25.
//

import Foundation
import Domain
import AuthenticationServices
import KakaoSDKUser
import KakaoSDKAuth
import KakaoSDKCommon

public final class DefaultAuthRepositoryImpl: NSObject, AuthRepository, @unchecked Sendable {
    public static let shared = DefaultAuthRepositoryImpl()

    private let lock = NSLock()
    private var _continuation: CheckedContinuation<String, Error>?

    override private init() {
        super.init()
    }

    // MARK: - Kakao SDK Setup
    @MainActor
    public func handleKakaoOpenURL(_ url: URL) async -> Bool {
        if AuthApi.isKakaoTalkLoginUrl(url) {
            return AuthController.handleOpenUrl(url: url)
        }
        return false
    }

    // MARK: - Apple Sign In
    public func signInWithApple() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            lock.lock()
            self._continuation = continuation
            lock.unlock()

            Task { @MainActor in
                let appleIDProvider = ASAuthorizationAppleIDProvider()
                let request = appleIDProvider.createRequest()
                request.requestedScopes = [.fullName, .email]

                let authorizationController = ASAuthorizationController(authorizationRequests: [request])
                authorizationController.delegate = self
                authorizationController.performRequests()
            }
        }
    }

    // MARK: - Kakao Login
    public func signInWithKakao() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                // 카카오톡 설치 여부 확인
                if UserApi.isKakaoTalkLoginAvailable() {
                    // 카카오톡으로 로그인
                    UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let token = oauthToken?.accessToken {
                            continuation.resume(returning: token)
                        } else {
                            continuation.resume(throwing: AuthError.invalidCredential)
                        }
                    }
                } else {
                    // 카카오 계정으로 로그인
                    UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let token = oauthToken?.accessToken {
                            continuation.resume(returning: token)
                        } else {
                            continuation.resume(throwing: AuthError.invalidCredential)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Private Helpers
    private func resumeWithToken(_ token: String) {
        lock.lock()
        let cont = _continuation
        _continuation = nil
        lock.unlock()
        cont?.resume(returning: token)
    }

    private func resumeWithError(_ error: Error) {
        lock.lock()
        let cont = _continuation
        _continuation = nil
        lock.unlock()
        cont?.resume(throwing: error)
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension DefaultAuthRepositoryImpl: ASAuthorizationControllerDelegate {
    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = appleIDCredential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            resumeWithError(AuthError.invalidCredential)
            return
        }

        resumeWithToken(tokenString)
    }

    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        resumeWithError(error)
    }
}

// MARK: - AuthError
public enum AuthError: LocalizedError {
    case invalidCredential
    case cancelled
    case notImplemented

    public var errorDescription: String? {
        switch self {
        case .invalidCredential:
            return "유효하지 않은 인증 정보입니다."
        case .cancelled:
            return "로그인이 취소되었습니다."
        case .notImplemented:
            return "아직 구현되지 않았습니다."
        }
    }
}
