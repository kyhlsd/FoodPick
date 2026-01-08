//
//  LocalChatRepository.swift
//  Domain
//
//  Created by 김영훈 on 1/8/26.
//

import Foundation

public protocol LocalChatRepository: Sendable {
    // ChatRoom
    func saveChatRoom(_ chatRoom: ChatRoom) async throws
    func saveChatRooms(_ chatRooms: [ChatRoom]) async throws
    func fetchChatRoom(roomId: String) async throws -> ChatRoom?
    func fetchAllChatRooms() async throws -> [ChatRoom]
    func fetchChatRooms(userId: String) async throws -> [ChatRoom]

    // ChatRoom Pagination (Offset 기반)
    func fetchChatRooms(userId: String, limit: Int, offset: Int) async throws -> [ChatRoom]

    func deleteChatRoom(roomId: String) async throws
    func deleteAllChatRooms() async throws

    // Chat
    func saveChat(_ chat: Chat) async throws
    func saveChats(_ chats: [Chat]) async throws
    func fetchChats(roomId: String) async throws -> [Chat]

    // Chat Pagination (커서 기반)
    /// 특정 시간 이전의 메시지를 가져옵니다 (과거 메시지 로드)
    func fetchChats(roomId: String, before date: Date, limit: Int) async throws -> [Chat]

    /// 특정 시간 이후의 메시지를 가져옵니다 (새 메시지 로드)
    func fetchChats(roomId: String, after date: Date, limit: Int) async throws -> [Chat]

    /// 최근 메시지를 지정된 개수만큼 가져옵니다
    func fetchRecentChats(roomId: String, limit: Int) async throws -> [Chat]

    func deleteChats(roomId: String) async throws
    func deleteAllChats() async throws

    // Update LastChat
    func updateLastChat(roomId: String, chat: Chat) async throws
}
