//
//  EventWebFeature.swift
//  Presentation
//
//  Created by 김영훈 on 12/23/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct EventWebFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable, Equatable {
        let urlPath: String
        var urlRequest: URLRequest?
        var accessToken: String?
        var isLoading = true
        @Presents var alert: AlertState<Alert>?
    }

    // MARK: - Action
    enum Action {
        case onAppear
        case authInfoLoaded(URLRequest, String)
        case authInfoLoadFailed(Error)
        case dismiss
        case attendanceCompleted(Int)
        case alert(PresentationAction<Alert>)
    }

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { [urlPath = state.urlPath] send in
                    do {
                        let authInfo = try await webViewService.getAuthenticationInfo(urlPath: urlPath)
                        await send(.authInfoLoaded(authInfo.urlRequest, authInfo.accessToken))
                    } catch {
                        await send(.authInfoLoadFailed(error))
                    }
                }

            case let .authInfoLoaded(urlRequest, accessToken):
                state.isLoading = false
                state.urlRequest = urlRequest
                state.accessToken = accessToken
                return .none

            case .authInfoLoadFailed:
                state.isLoading = false
                return .none

            case .dismiss:
                return .none

            case let .attendanceCompleted(attendanceCount):
                state.alert = AlertState {
                    TextState("\(attendanceCount)번째 출석이 완료되었습니다.")
                } actions: {
                    ButtonState(role: .cancel, action: .confirmAttendance) {
                        TextState("확인")
                    }
                }
                return .none

            case .alert(.presented(.confirmAttendance)):
                return .run { send in
                    await send(.dismiss)
                }

            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }

    // MARK: - Dependencies
    @Dependency(\.webViewService) var webViewService

    enum Alert: Sendable {
        case confirmAttendance
    }
}
