//
//  AppleSignInProviderImpl.swift
//  Data
//
//  Created by 김영훈 on 12/19/25.
//

import Foundation
import AuthenticationServices
import Domain

public final class AppleSignInProviderImpl: NSObject, AppleSignInProvider, @unchecked Sendable {
    public static let shared = AppleSignInProviderImpl()

    private let lock = NSLock()
    private var _continuation: CheckedContinuation<String, Error>?

    override private init() {
        super.init()
    }

    public func signIn() async throws -> String {
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
}

extension AppleSignInProviderImpl: ASAuthorizationControllerDelegate {
    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = appleIDCredential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            resumeWithError(AppleSignInError.invalidCredential)
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

public enum AppleSignInError: LocalizedError {
    case invalidCredential
    case cancelled

    public var errorDescription: String? {
        switch self {
        case .invalidCredential:
            return "유효하지 않은 Apple 인증 정보입니다."
        case .cancelled:
            return "Apple 로그인이 취소되었습니다."
        }
    }
}
