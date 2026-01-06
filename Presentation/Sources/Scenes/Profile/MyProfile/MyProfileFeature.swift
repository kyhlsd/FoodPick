//
//  MyProfileFeature.swift
//  Presentation
//
//  Created by 김영훈 on 1/6/26.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
struct MyProfileFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        enum Tab: String, CaseIterable, Sendable {
            case posts = "게시물"
            case likes = "좋아요"
        }

        var myProfile: MyProfile?
        var isLoading = false
        var isEditingNickname = false
        var editingNickname = ""
        var isUploadingImage = false
        var selectedTab: Tab = .posts
        var userPosts: [Post] = []
        var isLoadingPosts = false
        var likedRestaurants: [Restaurant] = []
        var isLoadingLikes = false

        @Presents var destination: Destination.State?
        @Presents var alert: AlertState<MyProfileFeature.Alert>?
        @Presents var confirmationDialog: ConfirmationDialogState<MyProfileFeature.ConfirmationDialog>?

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
        case onAppear
        case tabSelected(State.Tab)
        case fetchMyProfile
        case myProfileLoaded(MyProfile)
        case myProfileFailed(Error)
        case fetchUserPosts
        case userPostsLoaded([Post])
        case userPostsFailed(Error)
        case fetchMyLikes
        case myLikesLoaded([Restaurant])
        case myLikesFailed(Error)
        case postTapped(postId: String)
        case restaurantTapped(restaurantId: String)
        case searchButtonTapped
        case editNicknameTapped
        case cancelEditNickname
        case saveNickname
        case nicknameUpdated(MyProfile)
        case nicknameUpdateFailed(Error)
        case photoDataSelected(Data)
        case profileImageUploaded(String)
        case profileImageUploadFailed(Error)
        case settingsButtonTapped
        case logoutTapped
        case logoutConfirmed
        case logoutCompleted
        case logoutFailed(Error)
        case pushNotificationTapped
        case deviceTokenUpdated
        case deviceTokenUpdateFailed(Error)
        case destination(PresentationAction<Destination.Action>)
        case alert(PresentationAction<MyProfileFeature.Alert>)
        case confirmationDialog(PresentationAction<MyProfileFeature.ConfirmationDialog>)
    }

    // MARK: - Dependencies
    @Dependency(\.fetchMyProfile) var fetchMyProfileUseCase
    @Dependency(\.updateMyProfile) var updateMyProfileUseCase
    @Dependency(\.uploadProfileImage) var uploadProfileImageUseCase
    @Dependency(\.fetchUserPosts) var fetchUserPostsUseCase
    @Dependency(\.fetchMyLikedRestaurants) var fetchMyLikedUseCase
    @Dependency(\.logout) var logoutUseCase
    @Dependency(\.updateDeviceToken) var updateDeviceTokenUseCase
    @Dependency(\.getDeviceToken) var getDeviceTokenUseCase
    @Dependency(\.openURL) var openURL

    // MARK: - Body
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .onAppear:
                return .merge(
                    .send(.fetchMyProfile),
                    .send(.fetchUserPosts),
                    .send(.fetchMyLikes)
                )

            case let .tabSelected(tab):
                state.selectedTab = tab
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
                // 프로필 로드 후 게시물 다시 fetch
                return .send(.fetchUserPosts)

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

            case .fetchUserPosts:
                guard let userId = state.myProfile?.userId else {
                    // 프로필이 아직 로드되지 않았으면 대기
                    return .none
                }
                state.isLoadingPosts = true

                return .run { send in
                    do {
                        let response = try await fetchUserPostsUseCase.execute(
                            userId: userId,
                            request: BasicRequest(category: nil, next: nil, limit: 30)
                        )
                        await send(.userPostsLoaded(response.data))
                    } catch {
                        await send(.userPostsFailed(error))
                    }
                }

            case let .userPostsLoaded(posts):
                state.isLoadingPosts = false
                state.userPosts = posts
                return .none

            case let .userPostsFailed(error):
                state.isLoadingPosts = false
                state.alert = AlertState {
                    TextState("게시물 불러오기 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case .fetchMyLikes:
                state.isLoadingLikes = true

                return .run { send in
                    do {
                        let response = try await fetchMyLikedUseCase.execute(
                            request: BasicRequest(category: nil, next: nil, limit: 30)
                        )
                        await send(.myLikesLoaded(response.data))
                    } catch {
                        await send(.myLikesFailed(error))
                    }
                }

            case let .myLikesLoaded(restaurants):
                state.isLoadingLikes = false
                state.likedRestaurants = restaurants
                return .none

            case let .myLikesFailed(error):
                state.isLoadingLikes = false
                state.alert = AlertState {
                    TextState("좋아요 목록 불러오기 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case let .postTapped(postId):
                state.destination = .postDetail(
                    PostDetailFeature.State(postId: postId, myUserId: state.myProfile?.userId)
                )
                return .none

            case let .restaurantTapped(restaurantId):
                state.destination = .restaurantDetail(
                    RestaurantDetailFeature.State(restaurantId: restaurantId)
                )
                return .none

            case .searchButtonTapped:
                state.destination = .searchUser(
                    SearchUserFeature.State(myUserId: state.myProfile?.userId)
                )
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
                // RootFeature로 로그아웃 알림
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

            case .destination, .alert, .confirmationDialog:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .ifLet(\.$alert, action: \.alert)
        .ifLet(\.$confirmationDialog, action: \.confirmationDialog)
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
}

// MARK: - Destinations
extension MyProfileFeature {
    @Reducer
    enum Destination {
        case postDetail(PostDetailFeature)
        case restaurantDetail(RestaurantDetailFeature)
        case searchUser(SearchUserFeature)
    }
}

extension MyProfileFeature.Destination.State: Sendable {}
