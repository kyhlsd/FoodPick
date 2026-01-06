//
//  ProfileEditorFeature.swift
//  Presentation
//
//  Created by 김영훈 on 1/7/26.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
struct ProfileEditorFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        var myProfile: MyProfile?
        var isLoading = false
        var isEditingNickname = false
        var editingNickname = ""
        var isUploadingImage = false

        @Presents var alert: AlertState<Alert>?

        var displayNickname: String? {
            myProfile?.nickname
        }

        var displayProfileImage: String? {
            myProfile?.profileImage
        }

        var displayEmail: String? {
            myProfile?.email
        }
    }

    // MARK: - Action
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case fetchMyProfile
        case myProfileLoaded(MyProfile)
        case myProfileFailed(Error)
        case editNicknameTapped
        case cancelEditNickname
        case saveNickname
        case nicknameUpdated(MyProfile)
        case nicknameUpdateFailed(Error)
        case photoDataSelected(Data)
        case profileImageUploaded(String)
        case profileImageUploadFailed(Error)
        case alert(PresentationAction<Alert>)
    }

    enum Alert: Sendable {}

    // MARK: - Dependencies
    @Dependency(\.fetchMyProfile) var fetchMyProfileUseCase
    @Dependency(\.updateMyProfile) var updateMyProfileUseCase
    @Dependency(\.uploadProfileImage) var uploadProfileImageUseCase

    // MARK: - Body
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .fetchMyProfile:
                state.isLoading = true

                return .run { send in
                    do {
                        let myProfile = try await fetchMyProfileUseCase.execute()
                        await send(.myProfileLoaded(myProfile))
                    } catch {
                        await send(.myProfileFailed(error))
                    }
                }

            case let .myProfileLoaded(myProfile):
                state.isLoading = false
                state.myProfile = myProfile
                return .none

            case let .myProfileFailed(error):
                state.isLoading = false
                state.alert = AlertState {
                    TextState("프로필 로드 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case .editNicknameTapped:
                state.isEditingNickname = true
                state.editingNickname = state.displayNickname ?? ""
                return .none

            case .cancelEditNickname:
                state.isEditingNickname = false
                state.editingNickname = ""
                return .none

            case .saveNickname:
                guard !state.editingNickname.isEmpty else {
                    return .none
                }

                let nickname = state.editingNickname

                return .run { send in
                    do {
                        let updatedProfile = try await updateMyProfileUseCase.execute(
                            request: ProfileRequest(nickname: nickname)
                        )
                        await send(.nicknameUpdated(updatedProfile))
                    } catch {
                        await send(.nicknameUpdateFailed(error))
                    }
                }

            case let .nicknameUpdated(myProfile):
                state.isEditingNickname = false
                state.editingNickname = ""
                state.myProfile = myProfile
                return .none

            case let .nicknameUpdateFailed(error):
                state.alert = AlertState {
                    TextState("닉네임 수정 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case let .photoDataSelected(imageData):
                state.isUploadingImage = true

                return .run { send in
                    do {
                        let response = try await uploadProfileImageUseCase.execute(
                            imageData: imageData,
                            imageType: .jpg,
                            onProgress: nil
                        )

                        // 이미지 업로드 후 프로필 업데이트
                        let updatedProfile = try await updateMyProfileUseCase.execute(
                            request: ProfileRequest(profileImage: response.profileImage)
                        )
                        await send(.profileImageUploaded(updatedProfile.profileImage ?? ""))
                    } catch {
                        await send(.profileImageUploadFailed(error))
                    }
                }

            case let .profileImageUploaded(imagePath):
                state.isUploadingImage = false
                if let myProfile = state.myProfile {
                    state.myProfile = MyProfile(
                        userId: myProfile.userId,
                        email: myProfile.email,
                        nickname: myProfile.nickname,
                        profileImage: imagePath,
                        phoneNumber: myProfile.phoneNumber
                    )
                }
                return .none

            case let .profileImageUploadFailed(error):
                state.isUploadingImage = false
                state.alert = AlertState {
                    TextState("프로필 이미지 업로드 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
