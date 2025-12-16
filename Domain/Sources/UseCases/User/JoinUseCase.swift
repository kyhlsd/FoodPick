//
//  JoinUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public protocol JoinUseCase: Sendable {
    func execute(request: JoinRequest) async throws -> LoginResponse
}

public final class DefaultJoinUseCase: JoinUseCase, @unchecked Sendable {
    private let userRepository: UserRepository

    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    public func execute(request: JoinRequest) async throws -> LoginResponse {
        return try await userRepository.join(request)
    }
}
