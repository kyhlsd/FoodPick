//
//  CheckEmailDuplicationUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public protocol CheckEmailDuplicationUseCase: Sendable {
    func execute(email: String) async throws
}

public final class CheckEmailDuplicationUseCaseImpl: CheckEmailDuplicationUseCase, @unchecked Sendable {
    private let userRepository: UserRepository

    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    public func execute(email: String) async throws {
        try await userRepository.checkEmailDuplication(email)
    }
}
