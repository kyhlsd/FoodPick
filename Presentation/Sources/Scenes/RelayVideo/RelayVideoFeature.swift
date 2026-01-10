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
        var currentIndex: Int = 0
        var isLoading = false
        var selectedQuality: String = "auto"
        var isSubtitleEnabled = false
        var selectedSubtitle: Subtitle?
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
        case toggleSubtitle
        case selectQuality(String)
        case selectSubtitle(Subtitle?)
        case loadSubtitle(String, Subtitle)
        case subtitleLoaded(String, [SubtitleCue])
        case subtitleFailed(String, Error)
        case alert(PresentationAction<Alert>)
    }

    enum Alert: Sendable {}

    // MARK: - Dependencies
    @Dependency(\.fetchVideoList) var fetchVideoList
    @Dependency(\.fetchVideoStream) var fetchVideoStream
    @Dependency(\.likeVideo) var likeVideo
    @Dependency(\.fileService) var fileService
    @Dependency(\.subtitleParser) var subtitleParser

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

                // 현재 비디오의 스트림이면 기본 자막 설정 및 로드
                if state.currentVideo?.id == videoId {
                    if let defaultSubtitle = stream.subtitles.first(where: { $0.isDefault }) {
                        state.selectedSubtitle = defaultSubtitle

                        // 자막이 활성화되어 있으면 로드
                        if state.isSubtitleEnabled {
                            return .send(.loadSubtitle(videoId, defaultSubtitle))
                        }
                    }
                }
                return .none

            case let .streamFailed(videoId, error):
                // 스트림 로드 실패는 조용히 처리 (다음 비디오로 넘어갈 수 있도록)
                print("Failed to load stream for video \(videoId): \(error)")
                return .none

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
                // 좋아요 실패 시 원래 상태로 롤백 (optimistic update 취소)
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

            case .toggleSubtitle:
                state.isSubtitleEnabled.toggle()

                // 자막을 켰고, 선택된 자막이 있으면 로드
                if state.isSubtitleEnabled,
                   let subtitle = state.selectedSubtitle,
                   let videoId = state.currentVideo?.id {
                    return .send(.loadSubtitle(videoId, subtitle))
                }
                return .none

            case let .selectQuality(quality):
                state.selectedQuality = quality
                return .none

            case let .selectSubtitle(subtitle):
                state.selectedSubtitle = subtitle

                // 자막이 선택되고 활성화되어 있으면 로드
                if state.isSubtitleEnabled,
                   let subtitle = subtitle,
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
                        let request = try await fileService.makeAuthenticatedRequest(for: subtitle.url)
                        let (data, _) = try await URLSession.shared.data(for: request)

                        if let subtitleContent = String(data: data, encoding: .utf8) {
                            let cues = subtitleParser.parseWebVTT(subtitleContent)
                            await send(.subtitleLoaded(videoId, cues))
                        }
                    } catch {
                        await send(.subtitleFailed(videoId, error))
                    }
                }

            case let .subtitleLoaded(videoId, cues):
                state.loadedSubtitles[videoId] = cues
                return .none

            case let .subtitleFailed(videoId, error):
                print("Failed to load subtitle for video \(videoId): \(error)")
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
