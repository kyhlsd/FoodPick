//
//  LogoutUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public protocol LogoutUseCase: Sendable {
    func execute() async throws
}

public final class DefaultLogoutUseCase: LogoutUseCase, @unchecked Sendable {
    private let userRepository: UserRepository

    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    public func execute() async throws {
        try await userRepository.logout()
    }
}
