//
//  StoreRepository.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public protocol StoreRepository {
    func getStores(request: ByLocationRequest) async throws -> ResponseListWithCursor<Store>
    func getStoreInfo(id: String) async throws -> StoreDetail
    func toggleStoreLike(id: String, like: Bool) async throws -> LikeStatus
    func searchStores(name: String) async throws -> [Store]
    func getPopularStores(category: StoreCategory?) async throws -> [Store]
    func getPopularSearches() async throws -> [String]
    func getMyLikes(request: BasicRequest) async throws -> ResponseListWithCursor<Store>
    func getReviews(userId: String, request: BasicRequest) async throws -> ResponseListWithCursor<Review>
}
