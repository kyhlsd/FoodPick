//
//  UpdateDeviceTokenUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/19/25.
//

public protocol UpdateDeviceTokenUseCase: Sendable {
    func execute(deviceToken: String) async throws
}

public final class UpdateDeviceTokenUseCaseImpl: UpdateDeviceTokenUseCase, @unchecked Sendable {
    private let userRepository: UserRepository

    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    public func execute(deviceToken: String) async throws {
        try await userRepository.updateDeviceToken(deviceToken: deviceToken)
    }
}
