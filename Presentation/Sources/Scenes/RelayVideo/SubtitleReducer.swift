//
//  SubtitleReducer.swift
//  Presentation
//
//  Created by 김영훈 on 1/10/26.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
struct SubtitleReducer: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        var loadedSubtitles: [String: [SubtitleCue]] = [:]
        var subtitleLoadAttempts: [String: Int] = [:]
        var selectedSubtitle: Subtitle?
        var currentSubtitleText = ""

        var isSubtitleEnabled: Bool {
            selectedSubtitle != nil
        }

        func currentSubtitleCues(for videoId: String) -> [SubtitleCue] {
            return loadedSubtitles[videoId] ?? []
        }
    }

    // MARK: - Action
    enum Action: Sendable {
        case selectSubtitle(Subtitle?)
        case loadSubtitle(String, Subtitle)
        case subtitleLoaded(String, [SubtitleCue])
        case subtitleFailed(String, Error)
        case updateSubtitleForTime(String, TimeInterval) // videoId, currentTime
    }

    // MARK: - Dependencies
    @Dependency(\.fetchSubtitle) var fetchSubtitle

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .selectSubtitle(subtitle):
                state.selectedSubtitle = subtitle
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
                    state.subtitleLoadAttempts[videoId] = 0
                    return .none
                }

            case let .updateSubtitleForTime(videoId, currentTime):
                guard state.isSubtitleEnabled else {
                    if !state.currentSubtitleText.isEmpty {
                        state.currentSubtitleText = ""
                    }
                    return .none
                }

                let cues = state.currentSubtitleCues(for: videoId)

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
            }
        }
    }
}
