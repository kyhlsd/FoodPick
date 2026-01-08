//
//  ChatDependency.swift
//  Presentation
//
//  Created by 김영훈 on 12/19/25.
//

import Domain
import Data
import ComposableArchitecture

extension DependencyValues {

    // MARK: - Repository
    var chatRepository: ChatRepository {
        get { self[ChatRepositoryKey.self] }
        set { self[ChatRepositoryKey.self] = newValue }
    }

    var localChatRepository: LocalChatRepository {
        get { self[LocalChatRepositoryKey.self] }
        set { self[LocalChatRepositoryKey.self] = newValue }
    }

    var chatSocketRepository: ChatSocketRepository {
        get { self[ChatSocketRepositoryKey.self] }
        set { self[ChatSocketRepositoryKey.self] = newValue }
    }

    // MARK: - UseCases
    var fetchChatRoom: FetchChatRoomUseCase {
        get { self[FetchChatRoomKey.self] }
        set { self[FetchChatRoomKey.self] = newValue }
    }

    var fetchChatRoomList: FetchChatRoomListUseCase {
        get { self[FetchChatRoomListKey.self] }
        set { self[FetchChatRoomListKey.self] = newValue }
    }

    var sendMessage: SendMessageUseCase {
        get { self[SendMessageKey.self] }
        set { self[SendMessageKey.self] = newValue }
    }

    var fetchChatList: FetchChatListUseCase {
        get { self[FetchChatListKey.self] }
        set { self[FetchChatListKey.self] = newValue }
    }

    var uploadChatFiles: UploadChatFilesUseCase {
        get { self[UploadChatFilesKey.self] }
        set { self[UploadChatFilesKey.self] = newValue }
    }

    // Local Chat UseCases
    var fetchRecentChats: FetchRecentChatsUseCase {
        get { self[FetchRecentChatsKey.self] }
        set { self[FetchRecentChatsKey.self] = newValue }
    }

    var fetchOlderChats: FetchOlderChatsUseCase {
        get { self[FetchOlderChatsKey.self] }
        set { self[FetchOlderChatsKey.self] = newValue }
    }

    var saveLocalChat: SaveLocalChatUseCase {
        get { self[SaveLocalChatKey.self] }
        set { self[SaveLocalChatKey.self] = newValue }
    }

    var saveLocalChats: SaveLocalChatsUseCase {
        get { self[SaveLocalChatsKey.self] }
        set { self[SaveLocalChatsKey.self] = newValue }
    }

    // Socket UseCases
    var connectChatSocket: ConnectChatSocketUseCase {
        get { self[ConnectChatSocketKey.self] }
        set { self[ConnectChatSocketKey.self] = newValue }
    }

    var disconnectChatSocket: DisconnectChatSocketUseCase {
        get { self[DisconnectChatSocketKey.self] }
        set { self[DisconnectChatSocketKey.self] = newValue }
    }

    var receiveChatMessages: ReceiveChatMessagesUseCase {
        get { self[ReceiveChatMessagesKey.self] }
        set { self[ReceiveChatMessagesKey.self] = newValue }
    }

    var receiveChatErrors: ReceiveChatErrorsUseCase {
        get { self[ReceiveChatErrorsKey.self] }
        set { self[ReceiveChatErrorsKey.self] = newValue }
    }
}

// MARK: - Keys
private enum ChatRepositoryKey: DependencyKey {
    static let liveValue: ChatRepository = DefaultChatRepositoryImpl()
}

private enum LocalChatRepositoryKey: DependencyKey {
    static let liveValue: LocalChatRepository = DefaultLocalChatRepositoryImpl(database: .shared)
}

private enum ChatSocketRepositoryKey: DependencyKey {
    static let liveValue: ChatSocketRepository = DefaultChatSocketRepositoryImpl()
}

private enum FetchChatRoomKey: DependencyKey {
    static let liveValue: FetchChatRoomUseCase = {
        @Dependency(\.chatRepository) var chatRepository
        return FetchChatRoomUseCaseImpl(chatRepository: chatRepository)
    }()
}

private enum FetchChatRoomListKey: DependencyKey {
    static let liveValue: FetchChatRoomListUseCase = {
        @Dependency(\.chatRepository) var chatRepository
        return FetchChatRoomListUseCaseImpl(chatRepository: chatRepository)
    }()
}

private enum SendMessageKey: DependencyKey {
    static let liveValue: SendMessageUseCase = {
        @Dependency(\.chatRepository) var chatRepository
        return SendMessageUseCaseImpl(chatRepository: chatRepository)
    }()
}

private enum FetchChatListKey: DependencyKey {
    static let liveValue: FetchChatListUseCase = {
        @Dependency(\.chatRepository) var chatRepository
        return FetchChatListUseCaseImpl(chatRepository: chatRepository)
    }()
}

private enum UploadChatFilesKey: DependencyKey {
    static let liveValue: UploadChatFilesUseCase = {
        @Dependency(\.chatRepository) var chatRepository
        return UploadChatFilesUseCaseImpl(chatRepository: chatRepository)
    }()
}

private enum FetchRecentChatsKey: DependencyKey {
    static var liveValue: FetchRecentChatsUseCase {
        @Dependency(\.localChatRepository) var localChatRepository
        return FetchRecentChatsUseCaseImpl(localChatRepository: localChatRepository)
    }
}

private enum FetchOlderChatsKey: DependencyKey {
    static var liveValue: FetchOlderChatsUseCase {
        @Dependency(\.localChatRepository) var localChatRepository
        return FetchOlderChatsUseCaseImpl(localChatRepository: localChatRepository)
    }
}

private enum SaveLocalChatKey: DependencyKey {
    static var liveValue: SaveLocalChatUseCase {
        @Dependency(\.localChatRepository) var localChatRepository
        return SaveLocalChatUseCaseImpl(localChatRepository: localChatRepository)
    }
}

private enum SaveLocalChatsKey: DependencyKey {
    static var liveValue: SaveLocalChatsUseCase {
        @Dependency(\.localChatRepository) var localChatRepository
        return SaveLocalChatsUseCaseImpl(localChatRepository: localChatRepository)
    }
}

private enum ConnectChatSocketKey: DependencyKey {
    static let liveValue: ConnectChatSocketUseCase = {
        @Dependency(\.chatSocketRepository) var chatSocketRepository
        return ConnectChatSocketUseCaseImpl(chatSocketRepository: chatSocketRepository)
    }()
}

private enum DisconnectChatSocketKey: DependencyKey {
    static let liveValue: DisconnectChatSocketUseCase = {
        @Dependency(\.chatSocketRepository) var chatSocketRepository
        return DisconnectChatSocketUseCaseImpl(chatSocketRepository: chatSocketRepository)
    }()
}

private enum ReceiveChatMessagesKey: DependencyKey {
    static let liveValue: ReceiveChatMessagesUseCase = {
        @Dependency(\.chatSocketRepository) var chatSocketRepository
        return ReceiveChatMessagesUseCaseImpl(chatSocketRepository: chatSocketRepository)
    }()
}

private enum ReceiveChatErrorsKey: DependencyKey {
    static let liveValue: ReceiveChatErrorsUseCase = {
        @Dependency(\.chatSocketRepository) var chatSocketRepository
        return ReceiveChatErrorsUseCaseImpl(chatSocketRepository: chatSocketRepository)
    }()
}
