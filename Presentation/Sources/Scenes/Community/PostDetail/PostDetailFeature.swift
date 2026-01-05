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
        var commentText = ""
        var isSubmittingComment = false
        var editingCommentId: String?
        var editingCommentText = ""
        var selectedCommentId: String?

        @Presents var destination: Destination.State?
        @Presents var alert: AlertState<PostDetailFeature.Alert>?

        var isMyPost: Bool {
            guard let myUserId, let postDetail else {
                return false
            }
            return postDetail.creator.userId == myUserId
        }

        var canSubmitComment: Bool {
            !commentText.isEmpty && !isSubmittingComment
        }

        var canSubmitEditComment: Bool {
            !editingCommentText.isEmpty
        }

        func isMyComment(_ comment: Comment) -> Bool {
            guard let myUserId else { return false }
            return comment.creator.userId == myUserId
        }
    }

    // MARK: - Action
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case fetchPostDetail
        case postDetailLoaded(PostDetail)
        case postDetailFailed(Error)
        case imageIndexChanged(Int)
        case likePostTapped
        case likePostToggled(Bool)
        case likePostFailed(Error)
        case commentTextChanged(String)
        case submitCommentTapped
        case commentCreated(Comment)
        case commentFailed(Error)
        case moreButtonTapped
        case actionSheetDismissed
        case editPostTapped
        case deletePostTapped
        case commentMoreButtonTapped(commentId: String)
        case commentActionSheetDismissed
        case editCommentTapped(commentId: String, content: String)
        case cancelEditCommentTapped
        case editingCommentTextChanged(String)
        case submitEditCommentTapped(commentId: String)
        case commentEdited(Comment)
        case commentEditFailed(Error)
        case deleteCommentTapped(commentId: String)
        case commentDeleted(commentId: String)
        case commentDeleteFailed(Error)
        case destination(PresentationAction<Destination.Action>)
        case alert(PresentationAction<PostDetailFeature.Alert>)
    }

    // MARK: - Dependencies
    @Dependency(\.fetchPostDetail) var fetchPostDetailUseCase
    @Dependency(\.likePost) var likePostUseCase
    @Dependency(\.deletePost) var deletePostUseCase
    @Dependency(\.createComment) var createCommentUseCase
    @Dependency(\.editComment) var editCommentUseCase
    @Dependency(\.deleteComment) var deleteCommentUseCase
    @Dependency(\.dismiss) var dismiss

    // MARK: - Body
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

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

            case let .commentTextChanged(text):
                state.commentText = text
                return .none

            case .submitCommentTapped:
                guard !state.commentText.isEmpty else {
                    return .none
                }
                state.isSubmittingComment = true

                let commentText = state.commentText
                let postId = state.postId

                return .run { send in
                    do {
                        let comment = try await createCommentUseCase.execute(
                            postId: postId,
                            parentId: nil,
                            content: commentText
                        )
                        await send(.commentCreated(comment))
                    } catch {
                        await send(.commentFailed(error))
                    }
                }

            case let .commentCreated(comment):
                state.isSubmittingComment = false
                state.commentText = ""
                state.postDetail?.comments.append(comment)
                return .none

            case let .commentFailed(error):
                state.isSubmittingComment = false
                state.alert = AlertState {
                    TextState("댓글 작성 실패")
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

            case let .commentMoreButtonTapped(commentId):
                state.selectedCommentId = commentId
                return .none

            case .commentActionSheetDismissed:
                state.selectedCommentId = nil
                return .none

            case let .editCommentTapped(commentId, content):
                state.selectedCommentId = nil
                state.editingCommentId = commentId
                state.editingCommentText = content
                return .none

            case .cancelEditCommentTapped:
                state.editingCommentId = nil
                state.editingCommentText = ""
                return .none

            case let .editingCommentTextChanged(text):
                state.editingCommentText = text
                return .none

            case let .submitEditCommentTapped(commentId):
                guard !state.editingCommentText.isEmpty else {
                    return .none
                }

                let content = state.editingCommentText
                let postId = state.postId

                return .run { send in
                    do {
                        let updatedComment = try await editCommentUseCase.execute(
                            postId: postId,
                            commentId: commentId,
                            content: content
                        )
                        await send(.commentEdited(updatedComment))
                    } catch {
                        await send(.commentEditFailed(error))
                    }
                }

            case let .commentEdited(updatedComment):
                state.editingCommentId = nil
                state.editingCommentText = ""
                if let index = state.postDetail?.comments.firstIndex(where: {
                    $0.commentId == updatedComment.commentId
                }) {
                    state.postDetail?.comments[index] = updatedComment
                }
                return .none

            case let .commentEditFailed(error):
                state.alert = AlertState {
                    TextState("댓글 수정 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case let .deleteCommentTapped(commentId):
                state.selectedCommentId = nil

                let postId = state.postId

                return .run { send in
                    do {
                        try await deleteCommentUseCase.execute(postId: postId, commentId: commentId)
                        await send(.commentDeleted(commentId: commentId))
                    } catch {
                        await send(.commentDeleteFailed(error))
                    }
                }

            case let .commentDeleted(commentId):
                state.postDetail?.comments.removeAll { $0.commentId == commentId }
                return .none

            case let .commentDeleteFailed(error):
                state.alert = AlertState {
                    TextState("댓글 삭제 실패")
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

    // MARK: - Destination
    @Reducer
    enum Destination {
        case postWrite(PostWriteFeature)
    }
}

extension PostDetailFeature.Destination.State: Sendable {}
