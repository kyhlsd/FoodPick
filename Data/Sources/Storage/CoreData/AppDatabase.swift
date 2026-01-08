//
//  AppDatabase.swift
//  Data
//
//  Created by 김영훈 on 1/8/26.
//

import Foundation
@preconcurrency import CoreData

@MainActor
public final class AppDatabase {
    public static let shared = AppDatabase()

    private init() {
        setupContainer()
        setupNotifications()
    }

    // MARK: - Core Data Stack

    public lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FoodPick", managedObjectModel: managedObjectModel)

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unable to load persistent stores: \(error), \(error.userInfo)")
            }
        }

        // viewContext는 UI 업데이트 전용
        // Main thread에서만 사용되며, background context의 변경사항을 자동으로 merge
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)

        // Background context의 변경사항이 저장되면 자동으로 parent context로 merge
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true

        return container
    }()

    private lazy var managedObjectModel: NSManagedObjectModel = {
        let model = NSManagedObjectModel()

        // ChatEntity
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

        // ChatEntity - Unique Constraints (PK)
        chatEntity.uniquenessConstraints = [["chatId"]]

        // ChatEntity - Indexes
        let chatRoomIdIndex = NSFetchIndexDescription(name: "chatRoomIdIndex", elements: [
            NSFetchIndexElementDescription(property: chatRoomId, collationType: .binary)
        ])

        let chatCreatedAtIndex = NSFetchIndexDescription(name: "chatCreatedAtIndex", elements: [
            NSFetchIndexElementDescription(property: chatCreatedAt, collationType: .binary)
        ])

        // Compound index for roomId + createdAt (채팅방별 시간순 조회 최적화)
        let chatRoomIdCreatedAtIndex = NSFetchIndexDescription(name: "chatRoomIdCreatedAtIndex", elements: [
            NSFetchIndexElementDescription(property: chatRoomId, collationType: .binary),
            NSFetchIndexElementDescription(property: chatCreatedAt, collationType: .binary)
        ])

        chatEntity.indexes = [chatRoomIdIndex, chatCreatedAtIndex, chatRoomIdCreatedAtIndex]

        // ChatRoomEntity
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

        // ChatRoomEntity - Unique Constraints (PK)
        roomEntity.uniquenessConstraints = [["roomId"]]

        // ChatRoomEntity - Indexes
        let roomUpdatedAtIndex = NSFetchIndexDescription(name: "roomUpdatedAtIndex", elements: [
            NSFetchIndexElementDescription(property: roomUpdatedAt, collationType: .binary)
        ])

        roomEntity.indexes = [roomUpdatedAtIndex]

        // Relationships
        let roomToChats = NSRelationshipDescription()
        roomToChats.name = "chats"
        roomToChats.destinationEntity = chatEntity
        roomToChats.minCount = 0
        roomToChats.maxCount = 0 // to-many
        roomToChats.deleteRule = .cascadeDeleteRule

        let chatToRoom = NSRelationshipDescription()
        chatToRoom.name = "room"
        chatToRoom.destinationEntity = roomEntity
        chatToRoom.minCount = 0
        chatToRoom.maxCount = 1
        chatToRoom.deleteRule = .nullifyDeleteRule

        let roomToLastChat = NSRelationshipDescription()
        roomToLastChat.name = "lastChat"
        roomToLastChat.destinationEntity = chatEntity
        roomToLastChat.minCount = 0
        roomToLastChat.maxCount = 1
        roomToLastChat.deleteRule = .nullifyDeleteRule

        // Set inverse relationships
        roomToChats.inverseRelationship = chatToRoom
        chatToRoom.inverseRelationship = roomToChats

        chatEntity.properties.append(chatToRoom)
        roomEntity.properties.append(contentsOf: [roomToChats, roomToLastChat])

        model.entities = [chatEntity, roomEntity]

        return model
    }()

    // viewContext는 UI 업데이트 전용 (Main Thread Only)
    public var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - Setup

    private func setupContainer() {
        // 지연 초기화를 위해 비워둠
        _ = persistentContainer
    }

    private func setupNotifications() {
        // Background context 저장 시 viewContext와 merge
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(backgroundContextDidSave(_:)),
            name: .NSManagedObjectContextDidSave,
            object: nil
        )
    }

    @objc private func backgroundContextDidSave(_ notification: Notification) {
        guard let context = notification.object as? NSManagedObjectContext else { return }

        // background context의 변경사항을 viewContext에 merge
        // automaticallyMergesChangesFromParent가 true이므로 자동으로 처리되지만
        // 명시적으로 merge하여 즉시 UI에 반영
        if context.parent == nil && context != viewContext {
            // We are on the main actor and viewContext is main-queue,
            // so we can merge directly without capturing values in a @Sendable closure.
            viewContext.mergeChanges(fromContextDidSave: notification)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Save Context (UI용, Main Thread Only)

    public func saveViewContext() throws {
        // Already on @MainActor; viewContext is main-queue.
        if viewContext.hasChanges {
            try viewContext.save()
        }
    }

    // MARK: - Background Context (데이터 파싱/저장 전용)

    public func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        context.undoManager = nil
        return context
    }

    // Background context에서 작업 수행 (Thread-Safe)
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

    // Batch Delete 후 viewContext와 싱크
    public func batchDelete(entityName: String, predicate: NSPredicate? = nil) async throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = predicate

        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs

        // Execute delete on a background context and return deleted object IDs
        let deletedObjectIDs: [NSManagedObjectID] = try await performBackgroundTask { context in
            let result = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
            let objectIDs = result?.result as? [NSManagedObjectID] ?? []
            return objectIDs
        }

        guard !deletedObjectIDs.isEmpty else { return }

        // Merge back on the main actor
        let changes: [AnyHashable: Any] = [
            NSDeletedObjectsKey: deletedObjectIDs
        ]

        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: changes,
            into: [viewContext]
        )
    }

    // MARK: - Clear All Data

    public func clearAllData() async throws {
        // ChatEntity 삭제
        try await batchDelete(entityName: "ChatEntity")

        // ChatRoomEntity 삭제
        try await batchDelete(entityName: "ChatRoomEntity")

        // viewContext 메모리 캐시 초기화 (Already on @MainActor)
        viewContext.reset()
    }
}
