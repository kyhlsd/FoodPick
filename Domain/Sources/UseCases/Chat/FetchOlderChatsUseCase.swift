//
//  FetchOlderChatsUseCase.swift
//  Domain
//
//  Created by 김영훈 on 1/8/26.
//

import Foundation

public protocol FetchOlderChatsUseCase: Sendable {
    /// 특정 시간 이전의 메시지를 가져옵니다 (페이지네이션용)
    func execute(roomId: String, before date: Date, limit: Int) async throws -> [Chat]
}

public final class FetchOlderChatsUseCaseImpl: FetchOlderChatsUseCase, @unchecked Sendable {
    private let localChatRepository: LocalChatRepository

    public init(localChatRepository: LocalChatRepository) {
        self.localChatRepository = localChatRepository
    }

    public func execute(roomId: String, before date: Date, limit: Int) async throws -> [Chat] {
        return try await localChatRepository.fetchChats(roomId: roomId, before: date, limit: limit)
    }
}
