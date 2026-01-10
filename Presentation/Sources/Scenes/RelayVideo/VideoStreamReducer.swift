//
//  VideoStreamReducer.swift
//  Presentation
//
//  Created by 김영훈 on 1/10/26.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
struct VideoStreamReducer: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        var loadedStreams: [String: StreamResponse] = [:] // videoId -> StreamResponse
        var streamLoadAttempts: [String: Int] = [:] // videoId -> stream retry count

        func stream(for videoId: String) -> StreamResponse? {
            return loadedStreams[videoId]
        }
    }

    // MARK: - Action
    enum Action: Sendable {
        case loadStream(String) // videoId
        case streamLoaded(String, StreamResponse)
        case streamFailed(String, Error)
    }

    // MARK: - Dependencies
    @Dependency(\.fetchVideoStream) var fetchVideoStream

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .loadStream(videoId):
                // 이미 로드된 스트림이면 스킵
                if state.loadedStreams[videoId] != nil {
                    return .none
                }

                return .run { send in
                    do {
                        let stream = try await fetchVideoStream.execute(id: videoId)
                        await send(.streamLoaded(videoId, stream))
                    } catch {
                        await send(.streamFailed(videoId, error))
                    }
                }

            case let .streamLoaded(videoId, stream):
                state.loadedStreams[videoId] = stream
                state.streamLoadAttempts[videoId] = 0
                return .none

            case let .streamFailed(videoId, _):
                let attempts = state.streamLoadAttempts[videoId] ?? 0

                if attempts < 2 {
                    state.streamLoadAttempts[videoId] = attempts + 1
                    return .run { send in
                        try await Task.sleep(nanoseconds: 1_000_000_000)
                        do {
                            let stream = try await fetchVideoStream.execute(id: videoId)
                            await send(.streamLoaded(videoId, stream))
                        } catch {
                            await send(.streamFailed(videoId, error))
                        }
                    }
                } else {
                    state.streamLoadAttempts[videoId] = 0
                    return .none
                }
            }
        }
    }
}
