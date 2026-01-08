//
//  FetchRecentChatsUseCase.swift
//  Domain
//
//  Created by 김영훈 on 1/8/26.
//

import Foundation

public protocol FetchRecentChatsUseCase: Sendable {
    func execute(roomId: String, limit: Int) async throws -> [Chat]
}

public final class FetchRecentChatsUseCaseImpl: FetchRecentChatsUseCase, @unchecked Sendable {
    private let localChatRepository: LocalChatRepository

    public init(localChatRepository: LocalChatRepository) {
        self.localChatRepository = localChatRepository
    }

    public func execute(roomId: String, limit: Int) async throws -> [Chat] {
        return try await localChatRepository.fetchRecentChats(roomId: roomId, limit: limit)
    }
}
