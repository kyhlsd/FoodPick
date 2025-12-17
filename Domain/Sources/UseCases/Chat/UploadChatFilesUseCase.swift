//
//  UploadChatFilesUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Core

public protocol UploadChatFilesUseCase: Sendable {
    func execute(roomId: String, files: [(Data, ChatFileType)], onProgress: (@Sendable (Double) -> Void)?) async throws -> [String]
}

public final class UploadChatFilesUseCaseImpl: UploadChatFilesUseCase, @unchecked Sendable {
    private let chatRepository: ChatRepository

    public init(chatRepository: ChatRepository) {
        self.chatRepository = chatRepository
    }

    public func execute(roomId: String, files: [(Data, ChatFileType)], onProgress: (@Sendable (Double) -> Void)?) async throws -> [String] {
        return try await chatRepository.uploadFiles(roomId: roomId, files: files, onProgress: onProgress)
    }
}
