//
//  ReviewRepository.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Core

public protocol ReviewRepository: Sendable {
    func uploadFiles(storeId: String, files: [(Data, MediaType)]) async throws -> [String]
    func createReview(storeId: String, request: ReviewRequest) async throws -> ReviewResponse
    func fetchReviewList(storeId: String, request: ReviewPageRequest) async throws -> ResponseListWithCursor<ReviewForListResponse>
    func fetchReviewDetail(storeId: String, reviewId: String) async throws -> ReviewResponse
    func editReview(storeId: String, reviewId: String, request: EditReviewRequest) async throws -> ReviewResponse
    func deleteReview(storeId: String, reviewId: String) async throws
    func fetchStatistics(storeId: String) async throws -> [ReviewStatisticsItem]
}
