//
//  PostDetailFeature.swift
//  Presentation
//
//  Created by 김영훈 on 1/6/26.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
struct PostDetailFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        let postId: String
        let myUserId: String?
        var postDetail: PostDetail?
        var isLoading = false
        var currentImageIndex = 0
        var selectedPostId: String?

        @Presents var destination: Destination.State?
        @Presents var alert: AlertState<PostDetailFeature.Alert>?

        var isMyPost: Bool {
            guard let myUserId, let postDetail else {
                return false
            }
            return postDetail.creator.userId == myUserId
        }
    }

    // MARK: - Action
    enum Action {
        case onAppear
        case fetchPostDetail
        case postDetailLoaded(PostDetail)
        case postDetailFailed(Error)
        case imageIndexChanged(Int)
        case likePostTapped
        case likePostToggled(Bool)
        case likePostFailed(Error)
        case moreButtonTapped
        case actionSheetDismissed
        case editPostTapped
        case deletePostTapped
        case destination(PresentationAction<Destination.Action>)
        case alert(PresentationAction<PostDetailFeature.Alert>)
    }

    // MARK: - Dependencies
    @Dependency(\.fetchPostDetail) var fetchPostDetailUseCase
    @Dependency(\.likePost) var likePostUseCase
    @Dependency(\.deletePost) var deletePostUseCase
    @Dependency(\.dismiss) var dismiss

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.fetchPostDetail)

            case .fetchPostDetail:
                state.isLoading = true

                return .run { [postId = state.postId] send in
                    do {
                        let postDetail = try await fetchPostDetailUseCase.execute(id: postId)
                        await send(.postDetailLoaded(postDetail))
                    } catch {
                        await send(.postDetailFailed(error))
                    }
                }

            case let .postDetailLoaded(postDetail):
                state.isLoading = false
                state.postDetail = postDetail
                return .none

            case let .postDetailFailed(error):
                state.isLoading = false
                state.alert = AlertState {
                    TextState("포스트 로드 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case let .imageIndexChanged(index):
                state.currentImageIndex = index
                return .none

            case .likePostTapped:
                guard let postDetail = state.postDetail else {
                    return .none
                }

                let newLikeStatus = !postDetail.isLike

                return .run { [postId = state.postId] send in
                    do {
                        let result = try await likePostUseCase.execute(id: postId, like: newLikeStatus)
                        await send(.likePostToggled(result.likeStatus))
                    } catch {
                        await send(.likePostFailed(error))
                    }
                }

            case let .likePostToggled(likeStatus):
                state.postDetail?.isLike = likeStatus
                state.postDetail?.likeCount += likeStatus ? 1 : -1
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

            case .moreButtonTapped:
                state.selectedPostId = state.postId
                return .none

            case .actionSheetDismissed:
                state.selectedPostId = nil
                return .none

            case .editPostTapped:
                state.selectedPostId = nil
                state.destination = .postWrite(
                    PostWriteFeature.State(mode: .edit(postId: state.postId))
                )
                return .none

            case .deletePostTapped:
                state.selectedPostId = nil

                return .run { [postId = state.postId] _ in
                    do {
                        try await deletePostUseCase.execute(id: postId)
                        await dismiss()
                    } catch {
                        // 에러 처리
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
        case postWrite(PostWriteFeature)
    }
}

extension PostDetailFeature.Destination.State: Sendable {}
