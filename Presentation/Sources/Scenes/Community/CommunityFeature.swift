//
//  CommunityFeature.swift
//  Presentation
//
//  Created by 김영훈 on 1/3/26.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
struct CommunityFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        var posts: [Post] = []
        var isLoading = false
        var isLoadingMore = false
        var nextCursor: String?
        var orderBy: PostOrderBy = .createdAt
        var isShowingOrderByMenu = false
        var searchText = ""
        var selectedDistanceIndex: Int = 8
        var banner = BannerFeature.State()

        let distances = [100, 200, 300, 400, 500, 750, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000]

        var maxDistance: Int {
            distances[selectedDistanceIndex]
        }

        var canLoadMore: Bool {
            !isLoadingMore && nextCursor != "0" && nextCursor != nil
        }

        @Presents var destination: Destination.State?
        @Presents var alert: AlertState<CommunityFeature.Alert>?
    }

    // MARK: - Action
    enum Action {
        case onAppear
        case fetchPosts
        case postsLoaded(ResponseListWithCursor<Post>, isLoadingMore: Bool)
        case postsFailed(Error)
        case loadMore
        case orderByChanged(PostOrderBy)
        case toggleOrderByMenu
        case distanceChanged(Int)
        case searchTextChanged(String)
        case searchSubmitted
        case writePostTapped
        case likePostTapped(postId: String)
        case likePostToggled(postId: String, likeStatus: Bool)
        case likePostFailed(Error)
        case banner(BannerFeature.Action)
        case destination(PresentationAction<Destination.Action>)
        case alert(PresentationAction<CommunityFeature.Alert>)
    }

    // MARK: - Dependencies
    @Dependency(\.fetchPosts) var fetchPostsUseCase
    @Dependency(\.searchPosts) var searchPostsUseCase
    @Dependency(\.likePost) var likePostUseCase

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Scope(state: \.banner, action: \.banner) {
            BannerFeature()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    .send(.fetchPosts),
                    .send(.banner(.onAppear))
                )

            case .fetchPosts:
                guard !state.isLoading else { return .none }
                state.isLoading = true
                state.nextCursor = nil

                let request = PostByLocationRequest(
                    category: nil,
                    longitude: nil,
                    latitude: nil,
                    maxDistance: Float(state.maxDistance),
                    next: nil,
                    limit: 20,
                    orderBy: state.orderBy
                )

                return .run { send in
                    do {
                        let response = try await fetchPostsUseCase.execute(request: request)
                        await send(.postsLoaded(response, isLoadingMore: false))
                    } catch {
                        await send(.postsFailed(error))
                    }
                }

            case let .postsLoaded(response, isLoadingMore):
                state.isLoading = false
                state.isLoadingMore = false
                state.nextCursor = response.nextCursor

                if isLoadingMore {
                    state.posts.append(contentsOf: response.data)
                } else {
                    state.posts = response.data
                }
                return .none

            case let .postsFailed(error):
                state.isLoading = false
                state.isLoadingMore = false
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

            case .loadMore:
                guard state.canLoadMore, let cursor = state.nextCursor else {
                    return .none
                }
                state.isLoadingMore = true

                let request = PostByLocationRequest(
                    category: nil,
                    longitude: nil,
                    latitude: nil,
                    maxDistance: nil,
                    next: cursor,
                    limit: 20,
                    orderBy: state.orderBy
                )

                return .run { send in
                    do {
                        let response = try await fetchPostsUseCase.execute(request: request)
                        await send(.postsLoaded(response, isLoadingMore: true))
                    } catch {
                        await send(.postsFailed(error))
                    }
                }

            case let .orderByChanged(orderBy):
                state.orderBy = orderBy
                state.isShowingOrderByMenu = false
                return .send(.fetchPosts)

            case .toggleOrderByMenu:
                state.isShowingOrderByMenu.toggle()
                return .none

            case let .distanceChanged(index):
                state.selectedDistanceIndex = index
                return .send(.fetchPosts)

            case let .searchTextChanged(text):
                state.searchText = text
                return .none

            case .searchSubmitted:
                return .none

            case .writePostTapped:
                state.destination = .postWrite(PostWriteFeature.State())
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

            case .banner, .destination, .alert:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .ifLet(\.$alert, action: \.alert)
    }

    enum Alert: Sendable {}
}

// MARK: - Destinations
extension CommunityFeature {
    @Reducer
    enum Destination {
        case postWrite(PostWriteFeature)
    }
}

extension CommunityFeature.Destination.State: Sendable {}
