//
//  UploadReviewFilesUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Core

public protocol UploadReviewFilesUseCase: Sendable {
    func execute(restaurantId: String, files: [(Data, MediaType)]) async throws -> [String]
}

public final class UploadReviewFilesUseCaseImpl: UploadReviewFilesUseCase, @unchecked Sendable {
    private let reviewRepository: ReviewRepository

    public init(reviewRepository: ReviewRepository) {
        self.reviewRepository = reviewRepository
    }

    public func execute(restaurantId: String, files: [(Data, MediaType)]) async throws -> [String] {
        return try await reviewRepository.uploadFiles(restaurantId: restaurantId, files: files)
    }
}
