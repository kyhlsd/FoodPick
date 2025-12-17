//
//  FetchChatRoomListUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

public protocol FetchChatRoomListUseCase: Sendable {
    func execute() async throws -> [ChatRoom]
}

public final class FetchChatRoomListUseCaseImpl: FetchChatRoomListUseCase, @unchecked Sendable {
    private let chatRepository: ChatRepository

    public init(chatRepository: ChatRepository) {
        self.chatRepository = chatRepository
    }

    public func execute() async throws -> [ChatRoom] {
        return try await chatRepository.fetchChatRoomList()
    }
}
