//
//  SaveLocalChatUseCase.swift
//  Domain
//
//  Created by 김영훈 on 1/8/26.
//

import Foundation

public protocol SaveLocalChatUseCase: Sendable {
    /// 단일 채팅 메시지를 로컬에 저장합니다
    func execute(_ chat: Chat) async throws
}

public final class SaveLocalChatUseCaseImpl: SaveLocalChatUseCase, @unchecked Sendable {
    private let localChatRepository: LocalChatRepository

    public init(localChatRepository: LocalChatRepository) {
        self.localChatRepository = localChatRepository
    }

    public func execute(_ chat: Chat) async throws {
        try await localChatRepository.saveChat(chat)
    }
}
