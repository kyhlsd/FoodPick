//
//  DefaultLocalChatRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 1/8/26.
//

import Foundation
import CoreData
import Domain

public final class DefaultLocalChatRepositoryImpl: LocalChatRepository, @unchecked Sendable {
    private let database: AppDatabase

    public init(database: AppDatabase) {
        self.database = database
    }

    @MainActor
    public convenience init() {
        self.init(database: AppDatabase.shared)
    }

    // MARK: - ChatRoom

    public func saveChatRoom(_ chatRoom: ChatRoom) async throws {
        try await performInBackground { context in
            let fetchRequest = ChatRoomEntity.fetchRequest(roomId: chatRoom.roomId)
            let existing = try context.fetch(fetchRequest).first

            if let existing = existing {
                existing.update(from: chatRoom)
            } else {
                _ = ChatRoomEntity.create(from: chatRoom, in: context)
            }

            // lastChat 저장
            if let lastChat = chatRoom.lastChat {
                let chatFetchRequest = ChatEntity.fetchRequest()
                chatFetchRequest.predicate = NSPredicate(format: "chatId == %@", lastChat.chatId)
                let existingChat = try context.fetch(chatFetchRequest).first

                let chatEntity: ChatEntity
                if let existingChat = existingChat {
                    existingChat.update(from: lastChat)
                    chatEntity = existingChat
                } else {
                    chatEntity = ChatEntity.create(from: lastChat, in: context)
                }

                // room의 lastChat 설정
                if let roomEntity = try context.fetch(fetchRequest).first {
                    roomEntity.lastChat = chatEntity
                }
            }

            try context.save()
        }
    }

    public func saveChatRooms(_ chatRooms: [ChatRoom]) async throws {
        for chatRoom in chatRooms {
            try await saveChatRoom(chatRoom)
        }
    }

    public func fetchChatRoom(roomId: String) async throws -> ChatRoom? {
        return try await performInBackground { context in
            let fetchRequest = ChatRoomEntity.fetchRequest(roomId: roomId)
            guard let entity = try context.fetch(fetchRequest).first else {
                return nil
            }

            let participants = entity.participantUserIds.map { userId in
                Profile(userId: userId, nickname: "", profileImage: nil)
            }

            let lastChatData: Chat?
            if let lastChatEntity = entity.lastChat {
                let sender = Profile(userId: lastChatEntity.senderUserId, nickname: "", profileImage: nil)
                lastChatData = lastChatEntity.toDomain(sender: sender)
            } else {
                lastChatData = nil
            }

            return entity.toDomain(participants: participants, lastChatData: lastChatData)
        }
    }

    public func fetchAllChatRooms() async throws -> [ChatRoom] {
        return try await performInBackground { context in
            let fetchRequest = ChatRoomEntity.fetchAllRequest()
            let entities = try context.fetch(fetchRequest)

            return entities.map { entity in
                let participants = entity.participantUserIds.map { userId in
                    Profile(userId: userId, nickname: "", profileImage: nil)
                }

                let lastChatData: Chat?
                if let lastChatEntity = entity.lastChat {
                    let sender = Profile(userId: lastChatEntity.senderUserId, nickname: "", profileImage: nil)
                    lastChatData = lastChatEntity.toDomain(sender: sender)
                } else {
                    lastChatData = nil
                }

                return entity.toDomain(participants: participants, lastChatData: lastChatData)
            }
        }
    }

    public func fetchChatRooms(userId: String) async throws -> [ChatRoom] {
        return try await performInBackground { context in
            let fetchRequest = ChatRoomEntity.fetchRequest(userId: userId)
            let entities = try context.fetch(fetchRequest)

            return entities.map { entity in
                let participants = entity.participantUserIds.map { userId in
                    Profile(userId: userId, nickname: "", profileImage: nil)
                }

                let lastChatData: Chat?
                if let lastChatEntity = entity.lastChat {
                    let sender = Profile(userId: lastChatEntity.senderUserId, nickname: "", profileImage: nil)
                    lastChatData = lastChatEntity.toDomain(sender: sender)
                } else {
                    lastChatData = nil
                }

                return entity.toDomain(participants: participants, lastChatData: lastChatData)
            }
        }
    }

    // MARK: - ChatRoom Pagination

    public func fetchChatRooms(userId: String, limit: Int, offset: Int) async throws -> [ChatRoom] {
        return try await performInBackground { context in
            let fetchRequest = ChatRoomEntity.fetchRequest(userId: userId)
            fetchRequest.fetchLimit = limit
            fetchRequest.fetchOffset = offset

            let entities = try context.fetch(fetchRequest)

            return entities.map { entity in
                let participants = entity.participantUserIds.map { userId in
                    Profile(userId: userId, nickname: "", profileImage: nil)
                }

                let lastChatData: Chat?
                if let lastChatEntity = entity.lastChat {
                    let sender = Profile(userId: lastChatEntity.senderUserId, nickname: "", profileImage: nil)
                    lastChatData = lastChatEntity.toDomain(sender: sender)
                } else {
                    lastChatData = nil
                }

                return entity.toDomain(participants: participants, lastChatData: lastChatData)
            }
        }
    }

    public func deleteChatRoom(roomId: String) async throws {
        try await performInBackground { context in
            let fetchRequest = ChatRoomEntity.fetchRequest(roomId: roomId)
            let entities = try context.fetch(fetchRequest)

            for entity in entities {
                context.delete(entity)
            }

            try context.save()
        }
    }

    public func deleteAllChatRooms() async throws {
        try await performInBackground { context in
            let fetchRequest = ChatRoomEntity.fetchRequest()
            let entities = try context.fetch(fetchRequest)

            for entity in entities {
                context.delete(entity)
            }

            try context.save()
        }
    }

    // MARK: - Chat

    public func saveChat(_ chat: Chat) async throws {
        try await performInBackground { context in
            let fetchRequest = ChatEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "chatId == %@", chat.chatId)
            let existing = try context.fetch(fetchRequest).first

            if let existing = existing {
                existing.update(from: chat)
            } else {
                _ = ChatEntity.create(from: chat, in: context)
            }

            try context.save()
        }
    }

    public func saveChats(_ chats: [Chat]) async throws {
        for chat in chats {
            try await saveChat(chat)
        }
    }

    public func fetchChats(roomId: String) async throws -> [Chat] {
        return try await performInBackground { context in
            let fetchRequest = ChatEntity.fetchRequest(roomId: roomId)
            let entities = try context.fetch(fetchRequest)

            return entities.map { entity in
                let sender = Profile(userId: entity.senderUserId, nickname: "", profileImage: nil)
                return entity.toDomain(sender: sender)
            }
        }
    }

    // MARK: - Chat Pagination

    public func fetchChats(roomId: String, before date: Date, limit: Int) async throws -> [Chat] {
        return try await performInBackground { context in
            let fetchRequest = ChatEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(
                format: "roomId == %@ AND createdAt < %@",
                roomId,
                date as NSDate
            )
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            fetchRequest.fetchLimit = limit

            let entities = try context.fetch(fetchRequest)

            // 오름차순으로 반환 (오래된 것 → 최신 순)
            return entities.reversed().map { entity in
                let sender = Profile(userId: entity.senderUserId, nickname: "", profileImage: nil)
                return entity.toDomain(sender: sender)
            }
        }
    }

    public func fetchChats(roomId: String, after date: Date, limit: Int) async throws -> [Chat] {
        return try await performInBackground { context in
            let fetchRequest = ChatEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(
                format: "roomId == %@ AND createdAt > %@",
                roomId,
                date as NSDate
            )
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
            fetchRequest.fetchLimit = limit

            let entities = try context.fetch(fetchRequest)

            return entities.map { entity in
                let sender = Profile(userId: entity.senderUserId, nickname: "", profileImage: nil)
                return entity.toDomain(sender: sender)
            }
        }
    }

    public func fetchRecentChats(roomId: String, limit: Int) async throws -> [Chat] {
        return try await performInBackground { context in
            let fetchRequest = ChatEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "roomId == %@", roomId)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            fetchRequest.fetchLimit = limit

            let entities = try context.fetch(fetchRequest)

            // 오름차순으로 반환 (오래된 것 → 최신 순)
            return entities.reversed().map { entity in
                let sender = Profile(userId: entity.senderUserId, nickname: "", profileImage: nil)
                return entity.toDomain(sender: sender)
            }
        }
    }

    public func deleteChats(roomId: String) async throws {
        try await performInBackground { context in
            let fetchRequest = ChatEntity.fetchRequest(roomId: roomId)
            let entities = try context.fetch(fetchRequest)

            for entity in entities {
                context.delete(entity)
            }

            try context.save()
        }
    }

    public func deleteAllChats() async throws {
        try await performInBackground { context in
            let fetchRequest = ChatEntity.fetchRequest()
            let entities = try context.fetch(fetchRequest)

            for entity in entities {
                context.delete(entity)
            }

            try context.save()
        }
    }

    // MARK: - Update LastChat

    public func updateLastChat(roomId: String, chat: Chat) async throws {
        try await performInBackground { context in
            // ChatEntity 저장
            let chatFetchRequest = ChatEntity.fetchRequest()
            chatFetchRequest.predicate = NSPredicate(format: "chatId == %@", chat.chatId)
            let existingChat = try context.fetch(chatFetchRequest).first

            let chatEntity: ChatEntity
            if let existingChat = existingChat {
                existingChat.update(from: chat)
                chatEntity = existingChat
            } else {
                chatEntity = ChatEntity.create(from: chat, in: context)
            }

            // ChatRoomEntity의 lastChat 업데이트
            let roomFetchRequest = ChatRoomEntity.fetchRequest(roomId: roomId)
            if let roomEntity = try context.fetch(roomFetchRequest).first {
                roomEntity.lastChat = chatEntity
                roomEntity.updatedAt = chat.createdAt
            }

            try context.save()
        }
    }

    // MARK: - Helper Methods

    private func performInBackground<T: Sendable>(_ block: @Sendable @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        return try await database.performBackgroundTask(block)
    }
}
