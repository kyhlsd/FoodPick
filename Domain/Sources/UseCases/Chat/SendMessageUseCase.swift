//
//  SendMessageUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

public protocol SendMessageUseCase: Sendable {
    func execute(roomId: String, content: String, files: [String]) async throws -> Chat
}

public final class SendMessageUseCaseImpl: SendMessageUseCase, @unchecked Sendable {
    private let chatRepository: ChatRepository

    public init(chatRepository: ChatRepository) {
        self.chatRepository = chatRepository
    }

    public func execute(roomId: String, content: String, files: [String]) async throws -> Chat {
        return try await chatRepository.sendMessage(roomId: roomId, content: content, files: files)
    }
}
