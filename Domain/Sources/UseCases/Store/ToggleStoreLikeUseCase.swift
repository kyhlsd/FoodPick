//
//  ToggleStoreLikeUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public protocol ToggleStoreLikeUseCase: Sendable {
    func execute(id: String, like: Bool) async throws -> LikeStatus
}

public final class ToggleStoreLikeUseCaseImpl: ToggleStoreLikeUseCase, @unchecked Sendable {
    private let storeRepository: StoreRepository

    public init(storeRepository: StoreRepository) {
        self.storeRepository = storeRepository
    }

    public func execute(id: String, like: Bool) async throws -> LikeStatus {
        return try await storeRepository.toggleStoreLike(id: id, like: like)
    }
}
