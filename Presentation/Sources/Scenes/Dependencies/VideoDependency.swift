//
//  VideoDependency.swift
//  Presentation
//
//  Created by 김영훈 on 12/19/25.
//

import Domain
import Data
import ComposableArchitecture

extension DependencyValues {

    // MARK: - Repository
    var videoRepository: VideoRepository {
        get { self[VideoRepositoryKey.self] }
        set { self[VideoRepositoryKey.self] = newValue }
    }

    // MARK: - UseCases
    var fetchVideoList: FetchVideoListUseCase {
        get { self[FetchVideoListKey.self] }
        set { self[FetchVideoListKey.self] = newValue }
    }

    var fetchVideoStream: FetchVideoStreamUseCase {
        get { self[FetchVideoStreamKey.self] }
        set { self[FetchVideoStreamKey.self] = newValue }
    }

    var likeVideo: LikeVideoUseCase {
        get { self[LikeVideoKey.self] }
        set { self[LikeVideoKey.self] = newValue }
    }
}

// MARK: - Keys
private enum VideoRepositoryKey: DependencyKey {
    static let liveValue: VideoRepository = DefaultVideoRepositoryImpl()
}

private enum FetchVideoListKey: DependencyKey {
    static let liveValue: FetchVideoListUseCase = {
        @Dependency(\.videoRepository) var videoRepository
        return FetchVideoListUseCaseImpl(videoRepository: videoRepository)
    }()
}

private enum FetchVideoStreamKey: DependencyKey {
    static let liveValue: FetchVideoStreamUseCase = {
        @Dependency(\.videoRepository) var videoRepository
        return FetchVideoStreamUseCaseImpl(videoRepository: videoRepository)
    }()
}

private enum LikeVideoKey: DependencyKey {
    static let liveValue: LikeVideoUseCase = {
        @Dependency(\.videoRepository) var videoRepository
        return LikeVideoUseCaseImpl(videoRepository: videoRepository)
    }()
}
