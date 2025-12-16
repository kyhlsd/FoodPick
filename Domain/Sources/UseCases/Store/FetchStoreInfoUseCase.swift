//
//  FetchStoreInfoUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public protocol FetchStoreInfoUseCase: Sendable {
    func execute(id: String) async throws -> StoreDetail
}

public final class FetchStoreInfoUseCaseImpl: FetchStoreInfoUseCase, @unchecked Sendable {
    private let storeRepository: StoreRepository

    public init(storeRepository: StoreRepository) {
        self.storeRepository = storeRepository
    }

    public func execute(id: String) async throws -> StoreDetail {
        return try await storeRepository.getStoreInfo(id: id)
    }
}
