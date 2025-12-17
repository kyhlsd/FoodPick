//
//  FetchStoresUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public protocol FetchStoresUseCase: Sendable {
    func execute(request: StoreByLocationRequest) async throws -> ResponseListWithCursor<Store>
}

public final class FetchStoresUseCaseImpl: FetchStoresUseCase, @unchecked Sendable {
    private let storeRepository: StoreRepository

    public init(storeRepository: StoreRepository) {
        self.storeRepository = storeRepository
    }

    public func execute(request: StoreByLocationRequest) async throws -> ResponseListWithCursor<Store> {
        return try await storeRepository.fetchStores(request: request)
    }
}
