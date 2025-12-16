//
//  UploadProfileImageUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

import Foundation
import Core

public protocol UploadProfileImageUseCase: Sendable {
    func execute(imageData: Data, imageType: ProfileImageType, onProgress: (@Sendable (Double) -> Void)?) async throws -> ProfileImageResponse
}

public final class UploadProfileImageUseCaseImpl: UploadProfileImageUseCase, @unchecked Sendable {
    private let userRepository: UserRepository

    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    public func execute(imageData: Data, imageType: ProfileImageType, onProgress: (@Sendable (Double) -> Void)?) async throws -> ProfileImageResponse {
        return try await userRepository.uploadProfileImage(imageData, imageType: imageType, onProgress: onProgress)
    }
}
