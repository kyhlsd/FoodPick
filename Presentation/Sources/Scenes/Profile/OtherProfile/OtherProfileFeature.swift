//
//  OtherProfileFeature.swift
//  Presentation
//
//  Created by 김영훈 on 1/6/26.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
struct OtherProfileFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        let profile: Profile
        var userPosts: [Post] = []
        var isLoadingPosts = false
        var myUserId: String?

        @Presents var destination: Destination.State?
        @Presents var alert: AlertState<OtherProfileFeature.Alert>?
    }

    // MARK: - Action
    enum Action {
        case onAppear
        case fetchUserPosts
        case userPostsLoaded([Post])
        case userPostsFailed(Error)
        case postTapped(postId: String)
        case destination(PresentationAction<Destination.Action>)
        case alert(PresentationAction<OtherProfileFeature.Alert>)
    }

    // MARK: - Dependencies
    @Dependency(\.fetchUserPosts) var fetchUserPostsUseCase

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.fetchUserPosts)

            case .fetchUserPosts:
                state.isLoadingPosts = true
                let userId = state.profile.userId

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

            case let .postTapped(postId):
                state.destination = .postDetail(
                    PostDetailFeature.State(postId: postId, myUserId: state.myUserId)
                )
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
extension OtherProfileFeature {
    @Reducer
    enum Destination {
        case postDetail(PostDetailFeature)
    }
}

extension OtherProfileFeature.Destination.State: Sendable {}
