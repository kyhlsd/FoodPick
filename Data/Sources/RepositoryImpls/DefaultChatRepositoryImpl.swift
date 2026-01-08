//
//  DefaultChatRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Domain
import Core

public final class DefaultChatRepositoryImpl: ChatRepository, @unchecked Sendable {
    private let networkManager = NetworkManager.shared

    public init() {}

    public func fetchChatRoom(opponentId: String) async throws -> ChatRoom {
        guard let response = try await networkManager.request(
            ChatRouter.chatRoom(id: opponentId),
            responseType: ChatRoomDTO.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func fetchChatRoomList() async throws -> [ChatRoom] {
        guard let response = try await networkManager.request(
            ChatRouter.chatRoomList,
            responseType: ResponseListDTO<ChatRoomDTO>.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func sendMessage(roomId: String, content: String, files: [String]?) async throws -> Chat {
        guard let response = try await networkManager.request(
            ChatRouter.chat(id: roomId, content: content, files: files),
            responseType: ChatDTO.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func fetchChatList(roomId: String, time: Date?) async throws -> [Chat] {
        guard let response = try await networkManager.request(
            ChatRouter.chatList(id: roomId, time: time),
            responseType: ResponseListDTO<ChatDTO>.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func uploadFiles(roomId: String, files: [(Data, ChatFileType)], onProgress: (@Sendable (Double) -> Void)?) async throws -> [String] {
        let mediaFiles = files.map { ($0.0, $0.1.toMediaType) }
        guard let response = try await networkManager.request(
            ChatRouter.files(id: roomId, files: mediaFiles),
            responseType: FilesResponseDTO.self,
            onProgress: onProgress
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }
}
