//
//  VideoListReducer.swift
//  Presentation
//
//  Created by 김영훈 on 1/10/26.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
struct VideoListReducer: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        var videoList: [VideoResponse] = []
        var currentIndex: Int = 0
        var isLoading = false
        var nextCursor: String?

        var currentVideo: VideoResponse? {
            guard currentIndex < videoList.count else { return nil }
            return videoList[currentIndex]
        }
    }

    // MARK: - Action
    enum Action: Sendable {
        case fetchVideoList
        case videoListLoaded(VideoListResponse)
        case videoListFailed(Error)
        case scrollToIndex(Int)
    }

    // MARK: - Dependencies
    @Dependency(\.fetchVideoList) var fetchVideoList

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchVideoList:
                state.isLoading = true
                return .run { [nextCursor = state.nextCursor] send in
                    do {
                        let request = VideoPageRequest(next: nextCursor, limit: 10)
                        let response = try await fetchVideoList.execute(request: request)
                        await send(.videoListLoaded(response))
                    } catch {
                        await send(.videoListFailed(error))
                    }
                }

            case let .videoListLoaded(response):
                state.isLoading = false
                state.videoList.append(contentsOf: response.data)
                state.nextCursor = response.nextCursor
                return .none

            case .videoListFailed:
                state.isLoading = false
                return .none

            case let .scrollToIndex(index):
                guard index >= 0 && index < state.videoList.count else { return .none }
                state.currentIndex = index
                return .none
            }
        }
    }
}
