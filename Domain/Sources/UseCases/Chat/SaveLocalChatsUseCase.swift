//
//  SaveLocalChatsUseCase.swift
//  Domain
//
//  Created by 김영훈 on 1/8/26.
//

import Foundation

public protocol SaveLocalChatsUseCase: Sendable {
    /// 여러 채팅 메시지를 로컬에 일괄 저장합니다
    func execute(_ chats: [Chat]) async throws
}

public final class SaveLocalChatsUseCaseImpl: SaveLocalChatsUseCase, @unchecked Sendable {
    private let localChatRepository: LocalChatRepository

    public init(localChatRepository: LocalChatRepository) {
        self.localChatRepository = localChatRepository
    }

    public func execute(_ chats: [Chat]) async throws {
        try await localChatRepository.saveChats(chats)
    }
}
