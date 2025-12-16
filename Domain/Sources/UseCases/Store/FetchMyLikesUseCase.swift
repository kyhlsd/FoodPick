//
//  FetchMyLikesUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public protocol FetchMyLikesUseCase: Sendable {
    func execute(request: BasicRequest) async throws -> ResponseListWithCursor<Store>
}

public final class FetchMyLikesUseCaseImpl: FetchMyLikesUseCase, @unchecked Sendable {
    private let storeRepository: StoreRepository

    public init(storeRepository: StoreRepository) {
        self.storeRepository = storeRepository
    }

    public func execute(request: BasicRequest) async throws -> ResponseListWithCursor<Store> {
        return try await storeRepository.fetchMyLikes(request: request)
    }
}
