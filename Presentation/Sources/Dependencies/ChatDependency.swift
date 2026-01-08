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
}

// MARK: - Keys
private enum ChatRepositoryKey: DependencyKey {
    static let liveValue: ChatRepository = DefaultChatRepositoryImpl()
}

private enum LocalChatRepositoryKey: DependencyKey {
    // Construct on the main actor to satisfy the @MainActor convenience init.
    static var liveValue: LocalChatRepository {
        MainActor.assumeIsolated {
            DefaultLocalChatRepositoryImpl()
        }
    }
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
        MainActor.assumeIsolated {
            @Dependency(\.localChatRepository) var localChatRepository
            return FetchRecentChatsUseCaseImpl(localChatRepository: localChatRepository)
        }
    }
}

private enum FetchOlderChatsKey: DependencyKey {
    static var liveValue: FetchOlderChatsUseCase {
        MainActor.assumeIsolated {
            @Dependency(\.localChatRepository) var localChatRepository
            return FetchOlderChatsUseCaseImpl(localChatRepository: localChatRepository)
        }
    }
}

private enum SaveLocalChatKey: DependencyKey {
    static var liveValue: SaveLocalChatUseCase {
        MainActor.assumeIsolated {
            @Dependency(\.localChatRepository) var localChatRepository
            return SaveLocalChatUseCaseImpl(localChatRepository: localChatRepository)
        }
    }
}

private enum SaveLocalChatsKey: DependencyKey {
    static var liveValue: SaveLocalChatsUseCase {
        MainActor.assumeIsolated {
            @Dependency(\.localChatRepository) var localChatRepository
            return SaveLocalChatsUseCaseImpl(localChatRepository: localChatRepository)
        }
    }
}
