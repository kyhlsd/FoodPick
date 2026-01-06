//
//  MyProfileFeature.swift
//  Presentation
//
//  Created by 김영훈 on 1/6/26.
//

import Foundation
import Domain
import ComposableArchitecture
import PhotosUI
import SwiftUI

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
        var selectedPhotoItem: PhotosPickerItem?
        var isUploadingImage = false
        var selectedTab: Tab = .posts
        var userPosts: [Post] = []
        var isLoadingPosts = false
        var likedRestaurants: [Restaurant] = []
        var isLoadingLikes = false

        @Presents var destination: Destination.State?
        @Presents var alert: AlertState<MyProfileFeature.Alert>?

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
        case photoItemSelected
        case profileImageUploaded(String)
        case profileImageUploadFailed(Error)
        case destination(PresentationAction<Destination.Action>)
        case alert(PresentationAction<MyProfileFeature.Alert>)
    }

    // MARK: - Dependencies
    @Dependency(\.fetchMyProfile) var fetchMyProfileUseCase
    @Dependency(\.updateMyProfile) var updateMyProfileUseCase
    @Dependency(\.uploadProfileImage) var uploadProfileImageUseCase
    @Dependency(\.fetchUserPosts) var fetchUserPostsUseCase
    @Dependency(\.fetchMyLikedRestaurants) var fetchMyLikedUseCase

    // MARK: - Body
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.selectedPhotoItem):
                return .send(.photoItemSelected)

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

            case .photoItemSelected:
                guard let photoItem = state.selectedPhotoItem else {
                    return .none
                }
                state.isUploadingImage = true

                return .run { send in
                    do {
                        if let imageData = try await photoItem.loadTransferable(type: Data.self) {
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
                        }
                    } catch {
                        await send(.profileImageUploadFailed(error))
                    }
                }

            case let .profileImageUploaded(imagePath):
                state.isUploadingImage = false
                state.selectedPhotoItem = nil
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
                state.selectedPhotoItem = nil
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

            case .destination, .alert:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .ifLet(\.$alert, action: \.alert)
    }

    enum Alert: Sendable {}
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
