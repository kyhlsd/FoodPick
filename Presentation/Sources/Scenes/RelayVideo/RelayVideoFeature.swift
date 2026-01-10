//
//  RelayVideoFeature.swift
//  Presentation
//
//  Created by 김영훈 on 12/20/25.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
struct RelayVideoFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        var videoList: [VideoResponse] = []
        var loadedStreams: [String: StreamResponse] = [:] // videoId -> StreamResponse
        var loadedSubtitles: [String: [SubtitleCue]] = [:] // videoId -> SubtitleCues
        var streamLoadAttempts: [String: Int] = [:] // videoId -> stream retry count
        var subtitleLoadAttempts: [String: Int] = [:] // videoId -> subtitle retry count
        var currentIndex: Int = 0
        var isLoading = false
        var selectedQuality: String = "auto"
        var selectedSubtitle: Subtitle?
        var currentSubtitleText: String = ""
        var nextCursor: String?

        @Presents var alert: AlertState<Alert>?

        var currentVideo: VideoResponse? {
            guard currentIndex < videoList.count else { return nil }
            return videoList[currentIndex]
        }

        var currentStream: StreamResponse? {
            guard let videoId = currentVideo?.id else { return nil }
            return loadedStreams[videoId]
        }

        var isCurrentVideoLiked: Bool {
            currentVideo?.isLiked ?? false
        }

        var isSubtitleEnabled: Bool {
            selectedSubtitle != nil
        }

        var currentSubtitleCues: [SubtitleCue] {
            guard let videoId = currentVideo?.id else { return [] }
            return loadedSubtitles[videoId] ?? []
        }
    }

    // MARK: - Action
    enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case onAppear
        case fetchVideoList
        case videoListLoaded(VideoListResponse)
        case videoListFailed(Error)
        case scrollToIndex(Int)
        case loadStreamForCurrentVideo
        case streamLoaded(String, StreamResponse)
        case streamFailed(String, Error)
        case toggleLike
        case likeSuccess(String, LikeStatus)
        case likeFailed(Error)
        case selectQuality(String)
        case selectSubtitle(Subtitle?)
        case loadSubtitle(String, Subtitle)
        case subtitleLoaded(String, [SubtitleCue])
        case subtitleFailed(String, Error)
        case updateSubtitleForTime(TimeInterval)
        case alert(PresentationAction<Alert>)
    }

    enum Alert: Sendable {}

    // MARK: - Dependencies
    @Dependency(\.fetchVideoList) var fetchVideoList
    @Dependency(\.fetchVideoStream) var fetchVideoStream
    @Dependency(\.likeVideo) var likeVideo
    @Dependency(\.fetchSubtitle) var fetchSubtitle

    // MARK: - Body
    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.fetchVideoList)

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

                // 첫 번째 비디오의 스트림 로드
                if !response.data.isEmpty {
                    return .send(.loadStreamForCurrentVideo)
                }
                return .none

            case let .videoListFailed(error):
                state.isLoading = false
                state.alert = AlertState {
                    TextState("오류")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case let .scrollToIndex(index):
                guard index >= 0 && index < state.videoList.count else { return .none }
                state.currentIndex = index

                // 다음 페이지 로드 (마지막에서 2번째 비디오일 때)
                if index >= state.videoList.count - 2, state.nextCursor != nil {
                    return .merge(
                        .send(.loadStreamForCurrentVideo),
                        .send(.fetchVideoList)
                    )
                }

                return .send(.loadStreamForCurrentVideo)

            case .loadStreamForCurrentVideo:
                guard let currentVideo = state.currentVideo else { return .none }
                let videoId = currentVideo.id

                // 이미 로드된 스트림이면 스킵
                if state.loadedStreams[videoId] != nil {
                    // 기본 자막 설정
                    if let stream = state.loadedStreams[videoId],
                       let defaultSubtitle = stream.subtitles.first(where: { $0.isDefault }) {
                        state.selectedSubtitle = defaultSubtitle
                    }
                    return .none
                }

                // 스트림 로드
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
                state.streamLoadAttempts[videoId] = 0 // 성공 시 재시도 카운트 리셋

                // 현재 비디오의 스트림이면 기본 자막 설정 및 로드
                if state.currentVideo?.id == videoId {
                    if let defaultSubtitle = stream.subtitles.first(where: { $0.isDefault }) {
                        state.selectedSubtitle = defaultSubtitle
                        return .send(.loadSubtitle(videoId, defaultSubtitle))
                    }
                }
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
                    // 재시도 실패 시 카운트 리셋
                    state.streamLoadAttempts[videoId] = 0
                    return .none
                }

            case .toggleLike:
                guard let currentVideo = state.currentVideo else { return .none }
                let videoId = currentVideo.id
                let newLikeStatus = !currentVideo.isLiked

                // Optimistic update
                if let index = state.videoList.firstIndex(where: { $0.id == videoId }) {
                    state.videoList[index].isLiked = newLikeStatus
                    if newLikeStatus {
                        state.videoList[index].likeCount += 1
                    } else {
                        state.videoList[index].likeCount = max(0, state.videoList[index].likeCount - 1)
                    }
                }

                return .run { send in
                    do {
                        let status = try await likeVideo.execute(id: videoId, like: newLikeStatus)
                        await send(.likeSuccess(videoId, status))
                    } catch {
                        await send(.likeFailed(error))
                    }
                }

            case let .likeSuccess(videoId, status):
                // 서버 응답으로 최종 업데이트
                if let index = state.videoList.firstIndex(where: { $0.id == videoId }) {
                    state.videoList[index].isLiked = status.likeStatus
                }
                return .none

            case let .likeFailed(error):
                // 좋아요 실패 시 원래 상태로 롤백
                state.alert = AlertState {
                    TextState("좋아요 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case let .selectQuality(quality):
                state.selectedQuality = quality
                return .none

            case let .selectSubtitle(subtitle):
                state.selectedSubtitle = subtitle

                // 자막이 선택되었으면 로드
                if let subtitle,
                   let videoId = state.currentVideo?.id {
                    return .send(.loadSubtitle(videoId, subtitle))
                }
                return .none

            case let .loadSubtitle(videoId, subtitle):
                // 이미 로드된 자막이면 스킵
                if state.loadedSubtitles[videoId] != nil {
                    return .none
                }

                return .run { send in
                    do {
                        let cues = try await fetchSubtitle.execute(subtitle: subtitle)
                        await send(.subtitleLoaded(videoId, cues))
                    } catch {
                        await send(.subtitleFailed(videoId, error))
                    }
                }

            case let .subtitleLoaded(videoId, cues):
                state.loadedSubtitles[videoId] = cues
                state.subtitleLoadAttempts[videoId] = 0
                return .none

            case let .subtitleFailed(videoId, _):
                let attempts = state.subtitleLoadAttempts[videoId] ?? 0

                if attempts < 2, let subtitle = state.selectedSubtitle {
                    state.subtitleLoadAttempts[videoId] = attempts + 1
                    return .run { send in
                        try await Task.sleep(nanoseconds: 1_000_000_000)
                        do {
                            let cues = try await fetchSubtitle.execute(subtitle: subtitle)
                            await send(.subtitleLoaded(videoId, cues))
                        } catch {
                            await send(.subtitleFailed(videoId, error))
                        }
                    }
                } else {
                    // 재시도 실패 시 카운트 리셋
                    state.subtitleLoadAttempts[videoId] = 0
                    return .none
                }

            case let .updateSubtitleForTime(currentTime):
                guard state.isSubtitleEnabled else {
                    if !state.currentSubtitleText.isEmpty {
                        state.currentSubtitleText = ""
                    }
                    return .none
                }

                let cues = state.currentSubtitleCues

                // 현재 시간에 맞는 자막 찾기
                if let currentCue = cues.first(where: { $0.start <= currentTime && currentTime < $0.end }) {
                    if state.currentSubtitleText != currentCue.text {
                        state.currentSubtitleText = currentCue.text
                    }
                } else {
                    if !state.currentSubtitleText.isEmpty {
                        state.currentSubtitleText = ""
                    }
                }
                return .none

            case .alert:
                return .none

            case .binding:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
