//
//  ConnectChatSocketUseCase.swift
//  Domain
//
//  Created by 김영훈 on 1/8/26.
//

import Foundation

public protocol ConnectChatSocketUseCase: Sendable {
    func execute(roomId: String) async throws
}

public final class ConnectChatSocketUseCaseImpl: ConnectChatSocketUseCase, @unchecked Sendable {
    private let chatSocketRepository: ChatSocketRepository

    public init(chatSocketRepository: ChatSocketRepository) {
        self.chatSocketRepository = chatSocketRepository
    }

    public func execute(roomId: String) async throws {
        try await chatSocketRepository.connect(roomId: roomId)
    }
}
