//
//  ProfileContentFeature.swift
//  Presentation
//
//  Created by 김영훈 on 1/7/26.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
struct ProfileContentFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        enum Tab: String, CaseIterable, Sendable {
            case posts = "게시물"
            case likes = "좋아요"
        }

        var userId: String?
        var selectedTab: Tab = .posts
        var userPosts: [Post] = []
        var isLoadingPosts = false
        var likedRestaurants: [Restaurant] = []
        var isLoadingLikes = false

        @Presents var alert: AlertState<Alert>?
    }

    // MARK: - Action
    enum Action {
        case tabSelected(State.Tab)
        case fetchUserPosts(userId: String)
        case userPostsLoaded([Post])
        case userPostsFailed(Error)
        case fetchMyLikes
        case myLikesLoaded([Restaurant])
        case myLikesFailed(Error)
        case alert(PresentationAction<Alert>)
    }

    enum Alert: Sendable {}

    // MARK: - Dependencies
    @Dependency(\.fetchUserPosts) var fetchUserPostsUseCase
    @Dependency(\.fetchMyLikedRestaurants) var fetchMyLikedUseCase

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none

            case let .fetchUserPosts(userId):
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

            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
