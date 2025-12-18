//
//  ChatRepository.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Core

public protocol ChatRepository: Sendable {
    func fetchChatRoom(opponentId: String) async throws -> ChatRoom
    func fetchChatRoomList() async throws -> [ChatRoom]
    func sendMessage(roomId: String, content: String, files: [String]) async throws -> Chat
    func fetchChatList(roomId: String, time: Date?) async throws -> [Chat]
    func uploadFiles(roomId: String, files: [(Data, ChatFileType)], onProgress: (@Sendable (Double) -> Void)?) async throws -> [String]
}
