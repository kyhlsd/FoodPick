//
//  ChatEntity.swift
//  Data
//
//  Created by 김영훈 on 1/8/26.
//

import Foundation
import CoreData
import Domain

@objc(ChatEntity)
public class ChatEntity: NSManagedObject {
    @NSManaged public var chatId: String
    @NSManaged public var roomId: String
    @NSManaged public var content: String
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var senderUserId: String
    @NSManaged public var files: [String]?

    @NSManaged public var room: ChatRoomEntity?
}

// MARK: - Fetch Request
extension ChatEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChatEntity> {
        return NSFetchRequest<ChatEntity>(entityName: "ChatEntity")
    }

    // 특정 채팅방의 메시지 조회
    public class func fetchRequest(roomId: String) -> NSFetchRequest<ChatEntity> {
        let request = NSFetchRequest<ChatEntity>(entityName: "ChatEntity")
        request.predicate = NSPredicate(format: "roomId == %@", roomId)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        return request
    }
}

// MARK: - Domain Mapping
extension ChatEntity {
    func toDomain(sender: Profile) -> Chat {
        return Chat(
            chatId: chatId,
            roomId: roomId,
            content: content,
            createdAt: createdAt,
            updatedAt: updatedAt,
            sender: sender,
            files: files
        )
    }

    func update(from chat: Chat) {
        self.chatId = chat.chatId
        self.roomId = chat.roomId
        self.content = chat.content
        self.createdAt = chat.createdAt
        self.updatedAt = chat.updatedAt
        self.senderUserId = chat.sender.userId
        self.files = chat.files
    }

    static func create(from chat: Chat, in context: NSManagedObjectContext) -> ChatEntity {
        let entity = ChatEntity(context: context)
        entity.update(from: chat)
        return entity
    }
}
