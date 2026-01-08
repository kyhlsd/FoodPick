//
//  ReceiveChatErrorsUseCase.swift
//  Presentation
//
//  Created by 김영훈 on 1/8/26.
//

import Foundation

public protocol ReceiveChatErrorsUseCase: Sendable {
    func execute() -> AsyncStream<ChatSocketError>
}

public final class ReceiveChatErrorsUseCaseImpl: ReceiveChatErrorsUseCase, @unchecked Sendable {
    private let chatSocketRepository: ChatSocketRepository

    public init(chatSocketRepository: ChatSocketRepository) {
        self.chatSocketRepository = chatSocketRepository
    }

    public func execute() -> AsyncStream<ChatSocketError> {
        chatSocketRepository.errors()
    }
}
