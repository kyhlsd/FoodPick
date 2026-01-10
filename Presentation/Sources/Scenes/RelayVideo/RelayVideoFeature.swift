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
        var videoList = VideoListReducer.State()
        var videoStream = VideoStreamReducer.State()
        var subtitle = SubtitleReducer.State()
        var selectedQuality: String = "auto"

        @Presents var alert: AlertState<Alert>?

        // Computed properties for convenience
        var currentVideo: VideoResponse? {
            videoList.currentVideo
        }

        var currentStream: StreamResponse? {
            guard let videoId = currentVideo?.id else { return nil }
            return videoStream.stream(for: videoId)
        }

        var isCurrentVideoLiked: Bool {
            currentVideo?.isLiked ?? false
        }

        var currentSubtitleCues: [SubtitleCue] {
            guard let videoId = currentVideo?.id else { return [] }
            return subtitle.currentSubtitleCues(for: videoId)
        }

        var isSubtitleEnabled: Bool {
            subtitle.isSubtitleEnabled
        }

        var selectedSubtitle: Subtitle? {
            subtitle.selectedSubtitle
        }

        var currentSubtitleText: String {
            subtitle.currentSubtitleText
        }
    }

    // MARK: - Action
    enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case onAppear
        case videoList(VideoListReducer.Action)
        case videoStream(VideoStreamReducer.Action)
        case subtitle(SubtitleReducer.Action)
        case toggleLike
        case likeSuccess(String, LikeStatus)
        case likeFailed(Error)
        case selectQuality(String)
        case updatePlayerTime(TimeInterval)
        case alert(PresentationAction<Alert>)
    }

    enum Alert: Sendable {}

    // MARK: - Dependencies
    @Dependency(\.likeVideo) var likeVideo

    // MARK: - Body
    var body: some ReducerOf<Self> {
        BindingReducer()

        Scope(state: \.videoList, action: \.videoList) {
            VideoListReducer()
        }

        Scope(state: \.videoStream, action: \.videoStream) {
            VideoStreamReducer()
        }

        Scope(state: \.subtitle, action: \.subtitle) {
            SubtitleReducer()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.videoList(.fetchVideoList))

            case .videoList(.videoListLoaded):
                // 첫 번째 비디오의 스트림 로드
                if let videoId = state.currentVideo?.id {
                    return .send(.videoStream(.loadStream(videoId)))
                }
                return .none

            case .videoList(.videoListFailed(let error)):
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

            case let .videoList(.scrollToIndex(index)):
                // 다음 페이지 로드 (마지막에서 2번째 비디오일 때)
                if index >= state.videoList.videoList.count - 2,
                   state.videoList.nextCursor != nil {
                    return .merge(
                        .send(.videoList(.fetchVideoList)),
                        .send(.videoStream(.loadStream(state.videoList.videoList[index].id)))
                    )
                }

                // 현재 비디오의 스트림 로드
                if let videoId = state.currentVideo?.id {
                    return .send(.videoStream(.loadStream(videoId)))
                }
                return .none

            case let .videoStream(.streamLoaded(videoId, stream)):
                // 현재 비디오의 스트림이면 기본 자막 설정 및 로드
                if state.currentVideo?.id == videoId {
                    if let defaultSubtitle = stream.subtitles.first(where: { $0.isDefault }) {
                        return .merge(
                            .send(.subtitle(.selectSubtitle(defaultSubtitle))),
                            .send(.subtitle(.loadSubtitle(videoId, defaultSubtitle)))
                        )
                    }
                }
                return .none

            case let .subtitle(.selectSubtitle(subtitle)):
                // 자막이 선택되었으면 로드
                if let subtitle, let videoId = state.currentVideo?.id {
                    return .send(.subtitle(.loadSubtitle(videoId, subtitle)))
                }
                return .none

            case .toggleLike:
                guard let currentVideo = state.currentVideo else { return .none }
                let videoId = currentVideo.id
                let newLikeStatus = !currentVideo.isLiked

                // Optimistic update
                if let index = state.videoList.videoList.firstIndex(where: { $0.id == videoId }) {
                    state.videoList.videoList[index].isLiked = newLikeStatus
                    if newLikeStatus {
                        state.videoList.videoList[index].likeCount += 1
                    } else {
                        let currentLikeCount = state.videoList.videoList[index].likeCount
                        state.videoList.videoList[index].likeCount = max(0, currentLikeCount - 1)
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
                if let index = state.videoList.videoList.firstIndex(where: { $0.id == videoId }) {
                    state.videoList.videoList[index].isLiked = status.likeStatus
                }
                return .none

            case let .likeFailed(error):
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

            case let .updatePlayerTime(currentTime):
                guard let videoId = state.currentVideo?.id else { return .none }
                return .send(.subtitle(.updateSubtitleForTime(videoId, currentTime)))

            case .videoList, .videoStream, .subtitle, .alert, .binding:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
