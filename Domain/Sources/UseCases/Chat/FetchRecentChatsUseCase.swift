//
//  FetchRecentChatsUseCase.swift
//  Domain
//
//  Created by 김영훈 on 1/8/26.
//

import Foundation

public protocol FetchRecentChatsUseCase: Sendable {
    /// 최근 메시지를 지정된 개수만큼 가져옵니다 (초기 로드용)
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
