//
//  UploadProfileImageUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

import Foundation

public protocol UploadProfileImageUseCase: Sendable {
    func execute(imageData: Data, onProgress: (@Sendable (Double) -> Void)?) async throws -> UploadProfileImageResponse
}

public final class DefaultUploadProfileImageUseCase: UploadProfileImageUseCase, @unchecked Sendable {
    private let userRepository: UserRepository

    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    public func execute(imageData: Data, onProgress: (@Sendable (Double) -> Void)?) async throws -> UploadProfileImageResponse {
        return try await userRepository.uploadProfileImage(imageData, onProgress: onProgress)
    }
}
