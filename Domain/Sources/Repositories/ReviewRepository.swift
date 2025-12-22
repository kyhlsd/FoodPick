//
//  ReviewRepository.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Core

public protocol ReviewRepository: Sendable {
    func uploadFiles(restaurantId: String, files: [(Data, MediaType)]) async throws -> [String]
    func createReview(restaurantId: String, request: ReviewRequest) async throws -> ReviewResponse
    func fetchReviewList(restaurantId: String, request: ReviewPageRequest) async throws -> ResponseListWithCursor<ReviewForListResponse>
    func fetchReviewDetail(restaurantId: String, reviewId: String) async throws -> ReviewResponse
    func editReview(restaurantId: String, reviewId: String, request: EditReviewRequest) async throws -> ReviewResponse
    func deleteReview(restaurantId: String, reviewId: String) async throws
    func fetchStatistics(restaurantId: String) async throws -> [ReviewStatisticsItem]
}
