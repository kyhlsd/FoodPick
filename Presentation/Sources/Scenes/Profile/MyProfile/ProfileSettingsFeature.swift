//
//  ProfileSettingsFeature.swift
//  Presentation
//
//  Created by 김영훈 on 1/7/26.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
struct ProfileSettingsFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        @Presents var alert: AlertState<Alert>?
        @Presents var confirmationDialog: ConfirmationDialogState<ConfirmationDialog>?
    }

    // MARK: - Action
    enum Action {
        case settingsButtonTapped
        case logoutTapped
        case logoutConfirmed
        case logoutCompleted
        case logoutFailed(Error)
        case pushNotificationTapped
        case deviceTokenUpdated
        case deviceTokenUpdateFailed(Error)
        case alert(PresentationAction<Alert>)
        case confirmationDialog(PresentationAction<ConfirmationDialog>)
    }

    enum Alert: Sendable {
        case logoutConfirmed
        case openSettings
        case goToSettings
    }

    enum ConfirmationDialog: Sendable {
        case logout
        case pushNotification
    }

    // MARK: - Dependencies
    @Dependency(\.logout) var logoutUseCase
    @Dependency(\.updateDeviceToken) var updateDeviceTokenUseCase
    @Dependency(\.getDeviceToken) var getDeviceTokenUseCase
    @Dependency(\.openURL) var openURL

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .settingsButtonTapped:
                state.confirmationDialog = ConfirmationDialogState {
                    TextState("설정")
                } actions: {
                    ButtonState(action: .logout) {
                        TextState("로그아웃")
                    }
                    ButtonState(action: .pushNotification) {
                        TextState("Push 알림 권한 허용")
                    }
                    ButtonState(role: .cancel) {
                        TextState("취소")
                    }
                }
                return .none

            case .logoutTapped:
                state.alert = AlertState {
                    TextState("로그아웃")
                } actions: {
                    ButtonState(role: .destructive, action: .logoutConfirmed) {
                        TextState("로그아웃")
                    }
                    ButtonState(role: .cancel) {
                        TextState("취소")
                    }
                } message: {
                    TextState("로그아웃 하시겠습니까?")
                }
                return .none

            case .logoutConfirmed:
                return .run { send in
                    do {
                        try await logoutUseCase.execute()
                        await send(.logoutCompleted)
                    } catch {
                        await send(.logoutFailed(error))
                    }
                }

            case .logoutCompleted:
                // NotificationCenter로 로그아웃 알림
                NotificationCenter.default.post(name: .shouldNavigateToLogin, object: nil)
                return .none

            case let .logoutFailed(error):
                state.alert = AlertState {
                    TextState("로그아웃 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case .pushNotificationTapped:
                return .run { send in
                    do {
                        let deviceToken = try await getDeviceTokenUseCase.execute()
                        try await updateDeviceTokenUseCase.execute(deviceToken: deviceToken)
                        await send(.deviceTokenUpdated)
                    } catch {
                        // 권한 거부 등의 에러 발생 시 설정으로 안내
                        await send(.alert(.presented(.openSettings)))
                    }
                }

            case .deviceTokenUpdated:
                state.alert = AlertState {
                    TextState("알림 설정 완료")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState("Push 알림 설정이 허용되었습니다.")
                }
                return .none

            case let .deviceTokenUpdateFailed(error):
                state.alert = AlertState {
                    TextState("알림 설정 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case .confirmationDialog(.presented(.logout)):
                return .send(.logoutTapped)

            case .confirmationDialog(.presented(.pushNotification)):
                return .send(.pushNotificationTapped)

            case .alert(.presented(.logoutConfirmed)):
                return .send(.logoutConfirmed)

            case .alert(.presented(.openSettings)):
                state.alert = AlertState {
                    TextState("권한 필요")
                } actions: {
                    ButtonState(action: .goToSettings) {
                        TextState("설정으로 이동")
                    }
                    ButtonState(role: .cancel) {
                        TextState("취소")
                    }
                } message: {
                    TextState("설정에서 Push 알림 권한을 허용해주세요.")
                }
                return .none

            case .alert(.presented(.goToSettings)):
                return .run { _ in
                    if let url = URL(string: "app-settings:") {
                        await openURL(url)
                    }
                }

            case .alert, .confirmationDialog:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
        .ifLet(\.$confirmationDialog, action: \.confirmationDialog)
    }
}
