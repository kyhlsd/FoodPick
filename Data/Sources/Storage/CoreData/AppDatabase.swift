//
//  AppDatabase.swift
//  Data
//
//  Created by 김영훈 on 1/8/26.
//

import Foundation
import CoreData

public final class AppDatabase: Sendable {
    
    public static let shared = AppDatabase()
    
    public let persistentContainer: NSPersistentContainer
    
    private init() {
        let model = AppDatabase.makeManagedObjectModel()
        let container = NSPersistentContainer(name: "FoodPick", managedObjectModel: model)
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unable to load persistent stores: \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        
        self.persistentContainer = container
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(backgroundContextDidSave(_:)),
            name: .NSManagedObjectContextDidSave,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Main Actor Interface
    @MainActor
    public var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    @MainActor
    public func saveViewContext() throws {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            try context.save()
        }
    }
    
    // MARK: - Notification Handling
    @objc private func backgroundContextDidSave(_ notification: Notification) {
        guard let savedContext = notification.object as? NSManagedObjectContext else { return }
        if savedContext == persistentContainer.viewContext { return }
        if savedContext.persistentStoreCoordinator != persistentContainer.persistentStoreCoordinator {return }
        
        let mainContext = persistentContainer.viewContext
        
        if let userInfo = notification.userInfo {
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: userInfo,
                into: [mainContext]
            )
        }
    }
    
    // MARK: - Background Task
    public func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        context.undoManager = nil
        return context
    }
    
    public func performBackgroundTask<T>(_ block: @Sendable @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            persistentContainer.performBackgroundTask { context in
                context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
                context.undoManager = nil
                
                do {
                    let result = try block(context)
                    if context.hasChanges {
                        try context.save()
                    }
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Batch Operations
    public func batchDelete(entityName: String, predicate: NSPredicate? = nil) async throws {
        nonisolated(unsafe) let predicate = predicate
        
        let deletedObjectIDs: [NSManagedObjectID] = try await performBackgroundTask { context in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            fetchRequest.predicate = predicate
            
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            batchDeleteRequest.resultType = .resultTypeObjectIDs
            
            let result = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
            return result?.result as? [NSManagedObjectID] ?? []
        }
        
        guard !deletedObjectIDs.isEmpty else { return }
        
        await MainActor.run {
            let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: deletedObjectIDs]
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: changes,
                into: [self.persistentContainer.viewContext]
            )
        }
    }
    
    public func clearAllData() async throws {
        try await batchDelete(entityName: "ChatEntity")
        try await batchDelete(entityName: "ChatRoomEntity")
        
        await MainActor.run {
            self.persistentContainer.viewContext.reset()
        }
    }
    
    // MARK: - Model Factory
    private static func makeManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        // 엔티티 정의 가져오기
        let chatEntity = makeChatEntity()
        let roomEntity = makeChatRoomEntity()
        
        // Relationships 설정
        defineRelationships(chatEntity: chatEntity, roomEntity: roomEntity)
        
        // 모델에 엔티티 등록
        model.entities = [chatEntity, roomEntity]
        
        return model
    }
    
    // MARK: - Entity Definitions
    
    private static func makeChatEntity() -> NSEntityDescription {
        let chatEntity = NSEntityDescription()
        chatEntity.name = "ChatEntity"
        chatEntity.managedObjectClassName = "ChatEntity"
        
        let chatId = NSAttributeDescription()
        chatId.name = "chatId"
        chatId.type = .string
        chatId.isOptional = false
        
        let chatRoomId = NSAttributeDescription()
        chatRoomId.name = "roomId"
        chatRoomId.type = .string
        chatRoomId.isOptional = false
        
        let chatContent = NSAttributeDescription()
        chatContent.name = "content"
        chatContent.type = .string
        chatContent.isOptional = false
        
        let chatCreatedAt = NSAttributeDescription()
        chatCreatedAt.name = "createdAt"
        chatCreatedAt.type = .date
        chatCreatedAt.isOptional = false
        
        let chatUpdatedAt = NSAttributeDescription()
        chatUpdatedAt.name = "updatedAt"
        chatUpdatedAt.type = .date
        chatUpdatedAt.isOptional = false
        
        let senderUserId = NSAttributeDescription()
        senderUserId.name = "senderUserId"
        senderUserId.type = .string
        senderUserId.isOptional = false
        
        let files = NSAttributeDescription()
        files.name = "files"
        files.type = .transformable
        files.valueTransformerName = NSValueTransformerName.secureUnarchiveFromDataTransformerName.rawValue
        files.isOptional = true
        
        chatEntity.properties = [chatId, chatRoomId, chatContent, chatCreatedAt, chatUpdatedAt, senderUserId, files]
        chatEntity.uniquenessConstraints = [["chatId"]]
        
        // 인덱스 설정
        chatEntity.indexes = makeChatIndexes(chatRoomId: chatRoomId, chatCreatedAt: chatCreatedAt)
        
        return chatEntity
    }
    
    private static func makeChatRoomEntity() -> NSEntityDescription {
        let roomEntity = NSEntityDescription()
        roomEntity.name = "ChatRoomEntity"
        roomEntity.managedObjectClassName = "ChatRoomEntity"
        
        let roomId = NSAttributeDescription()
        roomId.name = "roomId"
        roomId.type = .string
        roomId.isOptional = false
        
        let roomCreatedAt = NSAttributeDescription()
        roomCreatedAt.name = "createdAt"
        roomCreatedAt.type = .date
        roomCreatedAt.isOptional = false
        
        let roomUpdatedAt = NSAttributeDescription()
        roomUpdatedAt.name = "updatedAt"
        roomUpdatedAt.type = .date
        roomUpdatedAt.isOptional = false
        
        let participantUserIds = NSAttributeDescription()
        participantUserIds.name = "participantUserIds"
        participantUserIds.type = .transformable
        participantUserIds.valueTransformerName = NSValueTransformerName.secureUnarchiveFromDataTransformerName.rawValue
        participantUserIds.isOptional = false
        
        roomEntity.properties = [roomId, roomCreatedAt, roomUpdatedAt, participantUserIds]
        roomEntity.uniquenessConstraints = [["roomId"]]
        
        // 인덱스 설정
        let roomUpdatedAtIndex = NSFetchIndexDescription(name: "roomUpdatedAtIndex", elements: [
            NSFetchIndexElementDescription(property: roomUpdatedAt, collationType: .binary)
        ])
        roomEntity.indexes = [roomUpdatedAtIndex]
        
        return roomEntity
    }
    
    // MARK: - Helper Methods
    private static func makeChatIndexes(chatRoomId: NSAttributeDescription, chatCreatedAt: NSAttributeDescription) -> [NSFetchIndexDescription] {
        let chatRoomIdIndex = NSFetchIndexDescription(name: "chatRoomIdIndex", elements: [
            NSFetchIndexElementDescription(property: chatRoomId, collationType: .binary)
        ])
        let chatCreatedAtIndex = NSFetchIndexDescription(name: "chatCreatedAtIndex", elements: [
            NSFetchIndexElementDescription(property: chatCreatedAt, collationType: .binary)
        ])
        let chatRoomIdCreatedAtIndex = NSFetchIndexDescription(name: "chatRoomIdCreatedAtIndex", elements: [
            NSFetchIndexElementDescription(property: chatRoomId, collationType: .binary),
            NSFetchIndexElementDescription(property: chatCreatedAt, collationType: .binary)
        ])
        return [chatRoomIdIndex, chatCreatedAtIndex, chatRoomIdCreatedAtIndex]
    }
    
    private static func defineRelationships(chatEntity: NSEntityDescription, roomEntity: NSEntityDescription) {
        // 1. ChatRoom -> Chats (1:N)
        let roomToChats = NSRelationshipDescription()
        roomToChats.name = "chats"
        roomToChats.destinationEntity = chatEntity
        roomToChats.minCount = 0
        roomToChats.maxCount = 0 // to-many
        roomToChats.deleteRule = .cascadeDeleteRule
        
        // 2. Chat -> ChatRoom (N:1)
        let chatToRoom = NSRelationshipDescription()
        chatToRoom.name = "room"
        chatToRoom.destinationEntity = roomEntity
        chatToRoom.minCount = 0
        chatToRoom.maxCount = 1
        chatToRoom.deleteRule = .nullifyDeleteRule
        
        // 3. ChatRoom -> LastChat (1:1)
        let roomToLastChat = NSRelationshipDescription()
        roomToLastChat.name = "lastChat"
        roomToLastChat.destinationEntity = chatEntity
        roomToLastChat.minCount = 0
        roomToLastChat.maxCount = 1
        roomToLastChat.deleteRule = .nullifyDeleteRule
        
        // Inverse 설정
        roomToChats.inverseRelationship = chatToRoom
        chatToRoom.inverseRelationship = roomToChats
        
        // 엔티티에 추가
        chatEntity.properties.append(chatToRoom)
        roomEntity.properties.append(contentsOf: [roomToChats, roomToLastChat])
    }
}
