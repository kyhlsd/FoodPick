//
//  SaveTokensUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/19/25.
//

import Foundation

public protocol SaveTokensUseCase: Sendable {
    func execute(accessToken: String, refreshToken: String) async throws
}

public final class SaveTokensUseCaseImpl: SaveTokensUseCase {
    private let tokenRepository: TokenRepository

    public init(tokenRepository: TokenRepository) {
        self.tokenRepository = tokenRepository
    }

    public func execute(accessToken: String, refreshToken: String) async throws {
        try await tokenRepository.saveAccessToken(accessToken)
        try await tokenRepository.saveRefreshToken(refreshToken)
    }
}
