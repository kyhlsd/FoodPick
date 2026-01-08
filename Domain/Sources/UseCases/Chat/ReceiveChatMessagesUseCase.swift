//
//  ReceiveChatMessagesUseCase.swift
//  Domain
//
//  Created by 김영훈 on 1/8/26.
//

import Foundation

public protocol ReceiveChatMessagesUseCase: Sendable {
    func execute() -> AsyncStream<Chat>
}

public final class ReceiveChatMessagesUseCaseImpl: ReceiveChatMessagesUseCase, @unchecked Sendable {
    private let chatSocketRepository: ChatSocketRepository

    public init(chatSocketRepository: ChatSocketRepository) {
        self.chatSocketRepository = chatSocketRepository
    }

    public func execute() -> AsyncStream<Chat> {
        return chatSocketRepository.receiveMessages()
    }
}
