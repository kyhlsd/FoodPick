//
//  PostSearchResultFeature.swift
//  Presentation
//
//  Created by 김영훈 on 1/6/26.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
struct PostSearchResultFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        let searchQuery: String
        let myUserId: String?
        var posts: [Post] = []
        var isLoading = false
        var selectedPostId: String?

        @Presents var destination: Destination.State?
        @Presents var alert: AlertState<PostSearchResultFeature.Alert>?
    }

    // MARK: - Action
    enum Action {
        case onAppear
        case searchPosts
        case postsLoaded([Post])
        case postsFailed(Error)
        case postTapped(postId: String)
        case likePostTapped(postId: String)
        case likePostToggled(postId: String, likeStatus: Bool)
        case likePostFailed(Error)
        case moreButtonTapped(postId: String)
        case actionSheetDismissed
        case editPostTapped(postId: String)
        case deletePostTapped(postId: String)
        case destination(PresentationAction<Destination.Action>)
        case alert(PresentationAction<PostSearchResultFeature.Alert>)
    }

    // MARK: - Dependencies
    @Dependency(\.searchPosts) var searchPostsUseCase
    @Dependency(\.likePost) var likePostUseCase
    @Dependency(\.deletePost) var deletePostUseCase

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.searchPosts)

            case .searchPosts:
                state.isLoading = true

                return .run { [query = state.searchQuery] send in
                    do {
                        let posts = try await searchPostsUseCase.execute(title: query)
                        await send(.postsLoaded(posts))
                    } catch {
                        await send(.postsFailed(error))
                    }
                }

            case let .postsLoaded(posts):
                state.isLoading = false
                state.posts = posts
                return .none

            case let .postsFailed(error):
                state.isLoading = false
                state.alert = AlertState {
                    TextState("검색 실패")
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

            case let .likePostTapped(postId):
                guard let post = state.posts.first(where: { $0.postId == postId }) else {
                    return .none
                }

                let newLikeStatus = !post.isLike

                return .run { send in
                    do {
                        let result = try await likePostUseCase.execute(id: postId, like: newLikeStatus)
                        await send(.likePostToggled(postId: postId, likeStatus: result.likeStatus))
                    } catch {
                        await send(.likePostFailed(error))
                    }
                }

            case let .likePostToggled(postId, likeStatus):
                if let index = state.posts.firstIndex(where: { $0.postId == postId }) {
                    state.posts[index].isLike = likeStatus
                    state.posts[index].likeCount += likeStatus ? 1 : -1
                }
                return .none

            case let .likePostFailed(error):
                state.alert = AlertState {
                    TextState("좋아요 처리 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case let .moreButtonTapped(postId):
                state.selectedPostId = postId
                return .none

            case .actionSheetDismissed:
                state.selectedPostId = nil
                return .none

            case let .editPostTapped(postId):
                state.selectedPostId = nil
                state.destination = .postWrite(
                    PostWriteFeature.State(mode: .edit(postId: postId))
                )
                return .none

            case let .deletePostTapped(postId):
                state.selectedPostId = nil

                return .run { send in
                    do {
                        try await deletePostUseCase.execute(id: postId)
                        // 삭제 후 다시 검색
                        await send(.searchPosts)
                    } catch {
                        await send(.postsFailed(error))
                    }
                }

            case .destination, .alert:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .ifLet(\.$alert, action: \.alert)
    }

    enum Alert: Sendable {}

    // MARK: - Destination
    @Reducer
    enum Destination {
        case postDetail(PostDetailFeature)
        case postWrite(PostWriteFeature)
    }
}

extension PostSearchResultFeature.State: Sendable {}
extension PostSearchResultFeature.Destination.State: Sendable {}
