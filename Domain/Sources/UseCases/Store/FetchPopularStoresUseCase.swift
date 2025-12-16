//
//  FetchPopularStoresUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public protocol FetchPopularStoresUseCase: Sendable {
    func execute(category: StoreCategory?) async throws -> [Store]
}

public final class FetchPopularStoresUseCaseImpl: FetchPopularStoresUseCase, @unchecked Sendable {
    private let storeRepository: StoreRepository

    public init(storeRepository: StoreRepository) {
        self.storeRepository = storeRepository
    }

    public func execute(category: StoreCategory?) async throws -> [Store] {
        return try await storeRepository.getPopularStores(category: category)
    }
}
