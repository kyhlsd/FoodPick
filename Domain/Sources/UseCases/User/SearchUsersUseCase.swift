//
//  SearchUsersUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public protocol SearchUsersUseCase: Sendable {
    func execute(nickname: String) async throws -> [Profile]
}

public final class DefaultSearchUsersUseCase: SearchUsersUseCase, @unchecked Sendable {
    private let userRepository: UserRepository

    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    public func execute(nickname: String) async throws -> [Profile] {
        return try await userRepository.searchUsers(nickname: nickname)
    }
}
