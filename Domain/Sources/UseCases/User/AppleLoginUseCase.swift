//
//  AppleLoginUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/19/25.
//

import Foundation

public protocol AppleLoginUseCase: Sendable {
    func execute() async throws -> String
}

public final class AppleLoginUseCaseImpl: AppleLoginUseCase {
    private let authRepository: AuthRepository

    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    public func execute() async throws -> String {
        return try await authRepository.signInWithApple()
    }
}
