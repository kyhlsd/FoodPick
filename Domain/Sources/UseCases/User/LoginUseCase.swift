//
//  LoginUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public enum LoginType: Sendable {
    case email(email: String, password: String)
    case kakao(oauthToken: String)
    case apple(idToken: String)
}

public protocol LoginUseCase: Sendable {
    func execute(type: LoginType) async throws -> LoginResponse
}

public final class DefaultLoginUseCase: LoginUseCase, @unchecked Sendable {
    private let userRepository: UserRepository

    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    public func execute(type: LoginType) async throws -> LoginResponse {
        switch type {
        case .email(let email, let password):
            return try await userRepository.emailLogin(email: email, password: password)
        case .kakao(let oauthToken):
            return try await userRepository.kakaoLogin(oauthToken: oauthToken)
        case .apple(let idToken):
            return try await userRepository.appleLogin(idToken: idToken)
        }
    }
}
