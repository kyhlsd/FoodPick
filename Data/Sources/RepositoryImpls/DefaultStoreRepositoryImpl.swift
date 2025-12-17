//
//  DefaultStoreRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Domain

public final class DefaultStoreRepositoryImpl: StoreRepository, @unchecked Sendable {
    private let networkManager = NetworkManager.shared

    public init() {}

    public func fetchStores(request: StoreByLocationRequest) async throws -> ResponseListWithCursor<Store> {
        let dto = ByLocationRequestDTO(from: request)
        guard let response = try await networkManager.request(
            StoreRouter.stores(dto: dto),
            responseType: ResponseListWithCursorDTO<StoreDTO>.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func fetchStoreInfo(id: String) async throws -> StoreDetail {
        guard let response = try await networkManager.request(
            StoreRouter.detail(id: id),
            responseType: StoreDetailDTO.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func toggleStoreLike(id: String, like: Bool) async throws -> LikeStatus {
        guard let response = try await networkManager.request(
            StoreRouter.like(id: id, like: like),
            responseType: LikeStatusDTO.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func searchStores(name: String) async throws -> [Store] {
        guard let response = try await networkManager.request(
            StoreRouter.search(name: name),
            responseType: ResponseListDTO<StoreDTO>.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func fetchPopularStores(category: StoreCategory?) async throws -> [Store] {
        guard let response = try await networkManager.request(
            StoreRouter.popularStores(category: category?.rawValue),
            responseType: ResponseListDTO<StoreDTO>.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func fetchPopularSearches() async throws -> [String] {
        guard let response = try await networkManager.request(
            StoreRouter.popularSearches,
            responseType: PopularSearchDTO.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func fetchMyLikes(request: BasicRequest) async throws -> ResponseListWithCursor<Store> {
        let dto = BasicRequestDTO(from: request)
        guard let response = try await networkManager.request(
            StoreRouter.myLikes(dto: dto),
            responseType: ResponseListWithCursorDTO<StoreDTO>.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func fetchReviews(userId: String, request: BasicRequest) async throws -> ResponseListWithCursor<ReviewForStore> {
        let dto = BasicRequestDTO(from: request)
        guard let response = try await networkManager.request(
            StoreRouter.reviews(id: userId, dto: dto),
            responseType: ResponseListWithCursorDTO<ReviewForStoreDTO>.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }
}
