//
//  DefaultReviewRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Domain
import Core

public final class DefaultReviewRepositoryImpl: ReviewRepository, @unchecked Sendable {
    private let networkManager = NetworkManager.shared

    public init() {}

    public func uploadFiles(restaurantId: String, files: [(Data, MediaType)]) async throws -> [String] {
        guard let response = try await networkManager.request(
            ReviewRouter.files(id: restaurantId, files: files),
            responseType: ReviewFilesResponseDTO.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func createReview(restaurantId: String, request: ReviewRequest) async throws -> ReviewResponse {
        guard let response = try await networkManager.request(
            ReviewRouter.review(id: restaurantId, dto: .init(from: request)),
            responseType: ReviewResponseDTO.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func fetchReviewList(restaurantId: String, request: ReviewPageRequest) async throws -> ResponseListWithCursor<ReviewForListResponse> {
        guard let response = try await networkManager.request(
            ReviewRouter.reviewList(id: restaurantId, dto: .init(from: request)),
            responseType: ResponseListWithCursorDTO<ReviewForListResponseDTO>.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func fetchReviewDetail(restaurantId: String, reviewId: String) async throws -> ReviewResponse {
        guard let response = try await networkManager.request(
            ReviewRouter.detail(restaurantId: restaurantId, reviewId: reviewId),
            responseType: ReviewResponseDTO.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func editReview(restaurantId: String, reviewId: String, request: EditReviewRequest) async throws -> ReviewResponse {
        guard let response = try await networkManager.request(
            ReviewRouter.edit(restaurantId: restaurantId, reviewId: reviewId, dto: .init(from: request)),
            responseType: ReviewResponseDTO.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func deleteReview(restaurantId: String, reviewId: String) async throws {
        try await networkManager.request(
            ReviewRouter.delete(restaurantId: restaurantId, reviewId: reviewId)
        )
    }

    public func fetchStatistics(restaurantId: String) async throws -> [ReviewStatisticsItem] {
        guard let response = try await networkManager.request(
            ReviewRouter.statistics(id: restaurantId),
            responseType: ResponseListDTO<ReviewStatisticsItemDTO>.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }
}
