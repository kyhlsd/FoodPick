//
//  KakaoLoginUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/19/25.
//

import Foundation

public protocol KakaoLoginUseCase: Sendable {
    func execute() async throws -> String
}

public final class KakaoLoginUseCaseImpl: KakaoLoginUseCase {
    private let authRepository: AuthRepository

    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    public func execute() async throws -> String {
        return try await authRepository.signInWithKakao()
    }
}
