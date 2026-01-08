//
//  DisconnectChatSocketUseCase.swift
//  Domain
//
//  Created by 김영훈 on 1/8/26.
//

import Foundation

public protocol DisconnectChatSocketUseCase: Sendable {
    func execute() async
}

public final class DisconnectChatSocketUseCaseImpl: DisconnectChatSocketUseCase, @unchecked Sendable {
    private let chatSocketRepository: ChatSocketRepository

    public init(chatSocketRepository: ChatSocketRepository) {
        self.chatSocketRepository = chatSocketRepository
    }

    public func execute() async {
        await chatSocketRepository.disconnect()
    }
}
