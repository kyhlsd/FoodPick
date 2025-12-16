//
//  SearchStoresUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public protocol SearchStoresUseCase: Sendable {
    func execute(name: String) async throws -> [Store]
}

public final class SearchStoresUseCaseImpl: SearchStoresUseCase, @unchecked Sendable {
    private let storeRepository: StoreRepository

    public init(storeRepository: StoreRepository) {
        self.storeRepository = storeRepository
    }

    public func execute(name: String) async throws -> [Store] {
        return try await storeRepository.searchStores(name: name)
    }
}
