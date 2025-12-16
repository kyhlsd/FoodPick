//
//  UpdateMyProfileUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public protocol UpdateMyProfileUseCase: Sendable {
    func execute(request: ProfileRequest) async throws -> MyProfile
}

public final class UpdateMyProfileUseCaseImpl: UpdateMyProfileUseCase, @unchecked Sendable {
    private let userRepository: UserRepository

    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    public func execute(request: ProfileRequest) async throws -> MyProfile {
        return try await userRepository.updateMyProfile(request)
    }
}
