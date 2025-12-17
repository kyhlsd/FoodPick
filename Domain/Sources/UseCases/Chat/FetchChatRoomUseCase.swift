//
//  FetchChatRoomUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

public protocol FetchChatRoomUseCase: Sendable {
    func execute(opponentId: String) async throws -> ChatRoom
}

public final class FetchChatRoomUseCaseImpl: FetchChatRoomUseCase, @unchecked Sendable {
    private let chatRepository: ChatRepository

    public init(chatRepository: ChatRepository) {
        self.chatRepository = chatRepository
    }

    public func execute(opponentId: String) async throws -> ChatRoom {
        return try await chatRepository.fetchChatRoom(opponentId: opponentId)
    }
}
