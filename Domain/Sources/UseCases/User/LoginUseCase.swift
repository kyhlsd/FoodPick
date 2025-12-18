//
//  LoginUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public enum LoginType: Sendable {
    case email(email: String, password: String, deviceToken: String)
    case kakao(oauthToken: String, deviceToken: String)
    case apple(idToken: String, deviceToken: String)
}

public protocol LoginUseCase: Sendable {
    func execute(type: LoginType) async throws -> LoginResponse
}

public final class LoginUseCaseImpl: LoginUseCase, @unchecked Sendable {
    private let userRepository: UserRepository

    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    public func execute(type: LoginType) async throws -> LoginResponse {
        switch type {
        case .email(let email, let password, let deviceToken):
            return try await userRepository.emailLogin(email: email, password: password, deviceToken: deviceToken)
        case .kakao(let oauthToken, let deviceToken):
            return try await userRepository.kakaoLogin(oauthToken: oauthToken, deviceToken: deviceToken)
        case .apple(let idToken, let deviceToken):
            return try await userRepository.appleLogin(idToken: idToken, deviceToken: deviceToken)
        }
    }
}
