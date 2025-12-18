//
//  StoreRepository.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public protocol StoreRepository: Sendable {
    func fetchStores(request: StoreByLocationRequest) async throws -> ResponseListWithCursor<Store>
    func fetchStoreInfo(id: String) async throws -> StoreDetail
    func toggleStoreLike(id: String, like: Bool) async throws -> LikeStatus
    func searchStores(name: String) async throws -> [Store]
    func fetchPopularStores(category: StoreCategory?) async throws -> [Store]
    func fetchPopularSearches() async throws -> [String]
    func fetchMyLikes(request: BasicRequest) async throws -> ResponseListWithCursor<Store>
    func fetchReviews(userId: String, request: BasicRequest) async throws -> ResponseListWithCursor<ReviewForStore>
}
