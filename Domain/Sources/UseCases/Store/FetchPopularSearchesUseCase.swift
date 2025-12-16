//
//  FetchPopularSearchesUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public protocol FetchPopularSearchesUseCase: Sendable {
    func execute() async throws -> [String]
}

public final class FetchPopularSearchesUseCaseImpl: FetchPopularSearchesUseCase, @unchecked Sendable {
    private let storeRepository: StoreRepository

    public init(storeRepository: StoreRepository) {
        self.storeRepository = storeRepository
    }

    public func execute() async throws -> [String] {
        return try await storeRepository.fetchPopularSearches()
    }
}
