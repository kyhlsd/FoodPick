//
//  RestaurantRepository.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public protocol RestaurantRepository: Sendable {
    func fetchRestaurants(request: RestaurantByLocationRequest) async throws -> ResponseListWithCursor<Restaurant>
    func fetchRestaurantInfo(id: String) async throws -> RestaurantDetail
    func toggleRestaurantLike(id: String, like: Bool) async throws -> LikeStatus
    func searchRestaurants(name: String) async throws -> [Restaurant]
    func fetchPopularRestaurants(category: RestaurantCategory?) async throws -> [Restaurant]
    func fetchPopularSearches() async throws -> [String]
    func fetchMyLikes(request: BasicRequest) async throws -> ResponseListWithCursor<Restaurant>
    func fetchReviews(userId: String, request: BasicRequest) async throws -> ResponseListWithCursor<ReviewForRestaurant>
}
