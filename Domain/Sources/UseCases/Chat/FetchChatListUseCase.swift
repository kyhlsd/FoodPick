//
//  FetchChatListUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public protocol FetchChatListUseCase: Sendable {
    func execute(roomId: String, time: Date?) async throws -> [Chat]
}

public final class FetchChatListUseCaseImpl: FetchChatListUseCase, @unchecked Sendable {
    private let chatRepository: ChatRepository

    public init(chatRepository: ChatRepository) {
        self.chatRepository = chatRepository
    }

    public func execute(roomId: String, time: Date?) async throws -> [Chat] {
        return try await chatRepository.fetchChatList(roomId: roomId, time: time)
    }
}
