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

    public func uploadFiles(storeId: String, files: [(Data, MediaType)]) async throws -> [String] {
        guard let response = try await networkManager.request(
            ReviewRouter.files(id: storeId, files: files),
            responseType: ReviewFilesResponseDTO.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func createReview(storeId: String, request: ReviewRequest) async throws -> ReviewResponse {
        guard let response = try await networkManager.request(
            ReviewRouter.review(id: storeId, dto: .init(from: request)),
            responseType: ReviewResponseDTO.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func fetchReviewList(storeId: String, request: ReviewPageRequest) async throws -> ResponseListWithCursor<ReviewForListResponse> {
        guard let response = try await networkManager.request(
            ReviewRouter.reviewList(id: storeId, dto: .init(from: request)),
            responseType: ResponseListWithCursorDTO<ReviewForListResponseDTO>.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func fetchReviewDetail(storeId: String, reviewId: String) async throws -> ReviewResponse {
        guard let response = try await networkManager.request(
            ReviewRouter.detail(storeId: storeId, reviewId: reviewId),
            responseType: ReviewResponseDTO.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func editReview(storeId: String, reviewId: String, request: EditReviewRequest) async throws -> ReviewResponse {
        guard let response = try await networkManager.request(
            ReviewRouter.edit(storeId: storeId, reviewId: reviewId, dto: .init(from: request)),
            responseType: ReviewResponseDTO.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func deleteReview(storeId: String, reviewId: String) async throws {
        try await networkManager.request(
            ReviewRouter.delete(storeId: storeId, reviewId: reviewId)
        )
    }

    public func fetchStatistics(storeId: String) async throws -> [ReviewStatisticsItem] {
        guard let response = try await networkManager.request(
            ReviewRouter.statistics(id: storeId),
            responseType: ResponseListDTO<ReviewStatisticsItemDTO>.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }
}
