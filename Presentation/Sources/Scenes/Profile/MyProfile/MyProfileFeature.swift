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
        var profileEditor = ProfileEditorFeature.State()
        var content = ProfileContentFeature.State()
        var settings = ProfileSettingsFeature.State()

        @Presents var destination: Destination.State?
    }

    // MARK: - Action
    enum Action {
        case onAppear
        case profileEditor(ProfileEditorFeature.Action)
        case content(ProfileContentFeature.Action)
        case settings(ProfileSettingsFeature.Action)
        case searchButtonTapped
        case postTapped(postId: String)
        case restaurantTapped(restaurantId: String)
        case destination(PresentationAction<Destination.Action>)
    }

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Scope(state: \.profileEditor, action: \.profileEditor) {
            ProfileEditorFeature()
        }

        Scope(state: \.content, action: \.content) {
            ProfileContentFeature()
        }

        Scope(state: \.settings, action: \.settings) {
            ProfileSettingsFeature()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    .send(.profileEditor(.fetchMyProfile)),
                    .send(.content(.fetchMyLikes))
                )

            case .profileEditor(.myProfileLoaded(let profile)):
                // 프로필 로드 후 게시물 fetch
                state.content.userId = profile.userId
                return .send(.content(.fetchUserPosts(userId: profile.userId)))

            case .profileEditor:
                return .none

            case .content:
                return .none

            case .settings:
                return .none

            case .searchButtonTapped:
                state.destination = .searchUser(
                    SearchUserFeature.State(myUserId: state.profileEditor.myProfile?.userId)
                )
                return .none

            case let .postTapped(postId):
                state.destination = .postDetail(
                    PostDetailFeature.State(postId: postId, myUserId: state.profileEditor.myProfile?.userId)
                )
                return .none

            case let .restaurantTapped(restaurantId):
                state.destination = .restaurantDetail(
                    RestaurantDetailFeature.State(restaurantId: restaurantId)
                )
                return .none

            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
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
