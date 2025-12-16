//
//  GetMyProfileUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public protocol GetMyProfileUseCase: Sendable {
    func execute() async throws -> MyProfile
}

public final class DefaultGetMyProfileUseCase: GetMyProfileUseCase, @unchecked Sendable {
    private let userRepository: UserRepository

    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    public func execute() async throws -> MyProfile {
        return try await userRepository.getMyProfile()
    }
}
