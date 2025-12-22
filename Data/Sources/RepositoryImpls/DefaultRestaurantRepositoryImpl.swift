//
//  DefaultRestaurantRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Domain

public final class DefaultRestaurantRepositoryImpl: RestaurantRepository, @unchecked Sendable {
    private let networkManager = NetworkManager.shared

    public init() {}

    public func fetchRestaurants(request: RestaurantByLocationRequest) async throws -> ResponseListWithCursor<Restaurant> {
        let dto = ByLocationRequestDTO(from: request)
        guard let response = try await networkManager.request(
            RestaurantRouter.restaurants(dto: dto),
            responseType: ResponseListWithCursorDTO<RestaurantDTO>.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func fetchRestaurantInfo(id: String) async throws -> RestaurantDetail {
        guard let response = try await networkManager.request(
            RestaurantRouter.detail(id: id),
            responseType: RestaurantDetailDTO.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func toggleRestaurantLike(id: String, like: Bool) async throws -> LikeStatus {
        guard let response = try await networkManager.request(
            RestaurantRouter.like(id: id, like: like),
            responseType: LikeStatusDTO.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func searchRestaurants(name: String) async throws -> [Restaurant] {
        guard let response = try await networkManager.request(
            RestaurantRouter.search(name: name),
            responseType: ResponseListDTO<RestaurantDTO>.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func fetchPopularRestaurants(category: RestaurantCategory?) async throws -> [Restaurant] {
        guard let response = try await networkManager.request(
            RestaurantRouter.popularRestaurants(category: category?.rawValue),
            responseType: ResponseListDTO<RestaurantDTO>.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func fetchPopularSearches() async throws -> [String] {
        guard let response = try await networkManager.request(
            RestaurantRouter.popularSearches,
            responseType: PopularSearchDTO.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func fetchMyLikes(request: BasicRequest) async throws -> ResponseListWithCursor<Restaurant> {
        let dto = BasicRequestDTO(from: request)
        guard let response = try await networkManager.request(
            RestaurantRouter.myLikes(dto: dto),
            responseType: ResponseListWithCursorDTO<RestaurantDTO>.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func fetchReviews(userId: String, request: BasicRequest) async throws -> ResponseListWithCursor<ReviewForRestaurant> {
        let dto = BasicRequestDTO(from: request)
        guard let response = try await networkManager.request(
            RestaurantRouter.reviews(id: userId, dto: dto),
            responseType: ResponseListWithCursorDTO<ReviewForRestaurantDTO>.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }
}
