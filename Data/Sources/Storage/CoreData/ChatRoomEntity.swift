//
//  ChatRoomEntity.swift
//  Data
//
//  Created by 김영훈 on 1/8/26.
//

import Foundation
import CoreData
import Domain

@objc(ChatRoomEntity)
public class ChatRoomEntity: NSManagedObject {
    @NSManaged public var roomId: String
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var participantUserIds: [String]

    // Relationships
    @NSManaged public var chats: NSSet?
    @NSManaged public var lastChat: ChatEntity?
}

// MARK: - Fetch Request
extension ChatRoomEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChatRoomEntity> {
        return NSFetchRequest<ChatRoomEntity>(entityName: "ChatRoomEntity")
    }

    // 모든 채팅방 조회 (최근 업데이트 순)
    public class func fetchAllRequest() -> NSFetchRequest<ChatRoomEntity> {
        let request = NSFetchRequest<ChatRoomEntity>(entityName: "ChatRoomEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        return request
    }

    // 특정 채팅방 조회
    public class func fetchRequest(roomId: String) -> NSFetchRequest<ChatRoomEntity> {
        let request = NSFetchRequest<ChatRoomEntity>(entityName: "ChatRoomEntity")
        request.predicate = NSPredicate(format: "roomId == %@", roomId)
        return request
    }

    // 특정 사용자가 포함된 채팅방 조회
    public class func fetchRequest(userId: String) -> NSFetchRequest<ChatRoomEntity> {
        let request = NSFetchRequest<ChatRoomEntity>(entityName: "ChatRoomEntity")
        request.predicate = NSPredicate(format: "ANY participantUserIds == %@", userId)
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        return request
    }
}

// MARK: - Relationship Helpers
extension ChatRoomEntity {
    @objc(addChatsObject:)
    @NSManaged public func addToChats(_ value: ChatEntity)

    @objc(removeChatsObject:)
    @NSManaged public func removeFromChats(_ value: ChatEntity)

    @objc(addChats:)
    @NSManaged public func addToChats(_ values: NSSet)

    @objc(removeChats:)
    @NSManaged public func removeFromChats(_ values: NSSet)
}

// MARK: - Domain Mapping
extension ChatRoomEntity {
    func toDomain(participants: [Profile], lastChatData: Chat?) -> ChatRoom {
        return ChatRoom(
            roomId: roomId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            participants: participants,
            lastChat: lastChatData
        )
    }

    func update(from chatRoom: ChatRoom) {
        self.roomId = chatRoom.roomId
        self.createdAt = chatRoom.createdAt
        self.updatedAt = chatRoom.updatedAt
        self.participantUserIds = chatRoom.participants.map { $0.userId }
    }

    static func create(from chatRoom: ChatRoom, in context: NSManagedObjectContext) -> ChatRoomEntity {
        let entity = ChatRoomEntity(context: context)
        entity.update(from: chatRoom)
        return entity
    }
}
