//
//  PostSearchResultView.swift
//  Presentation
//
//  Created by 김영훈 on 1/6/26.
//

import SwiftUI
import Domain
import ComposableArchitecture

struct PostSearchResultView: View {
    let store: StoreOf<PostSearchResultFeature>

    var body: some View {
        WithPerceptionTracking {
            @Perception.Bindable var store = store

            let selectedPostId = store.selectedPostId
            let myUserId = store.myUserId

            ZStack {
                Color.custom(.gray(.gray15))
                    .ignoresSafeArea()

                if store.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .custom(.brand(.blackSprout))))
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: AppPadding.medium.value) {
                            // 검색 결과 헤더
                            SearchedHeaderView(searchText: store.searchQuery, count: store.posts.count)

                            // 검색 결과 목록
                            if store.posts.isEmpty {
                                Text("검색 결과가 없습니다")
                                    .font(.pretendard(size: .body2, weight: .medium))
                                    .foregroundStyle(.custom(.gray(.gray60)))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 60)
                            } else {
                                VStack(spacing: AppPadding.medium.value) {
                                    ForEach(store.posts, id: \.postId) { post in
                                        let isMyPost = myUserId != nil && post.creator.userId == myUserId
                                        
                                        Button {
                                            store.send(.postTapped(postId: post.postId))
                                        } label: {
                                            PostItemView(
                                                post: post,
                                                isMyPost: isMyPost,
                                                onLikePostTapped: { postId in
                                                    store.send(.likePostTapped(postId: postId))
                                                },
                                                onMoreTapped: isMyPost ? {
                                                    store.send(.moreButtonTapped(postId: post.postId))
                                                } : nil
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }

                            Spacer(minLength: 110)
                        }
                        .padding(.horizontal, .xLarge)
                    }
                }
            }
            .navigationTitle("게시물 검색")
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog(
                "",
                isPresented: Binding(
                    get: { selectedPostId != nil },
                    set: { if !$0 { store.send(.actionSheetDismissed) } }
                ),
                titleVisibility: .hidden
            ) {
                if let postId = store.selectedPostId {
                    Button("포스트 수정") {
                        store.send(.editPostTapped(postId: postId))
                    }
                    Button("포스트 삭제", role: .destructive) {
                        store.send(.deletePostTapped(postId: postId))
                    }
                    Button("취소", role: .cancel) {
                        store.send(.actionSheetDismissed)
                    }
                }
            }
            .alert($store.scope(state: \.alert, action: \.alert))
            .navigationDestination(
                item: $store.scope(state: \.destination?.postDetail, action: \.destination.postDetail)
            ) { store in
                PostDetailView(store: store)
            }
            .navigationDestination(
                item: $store.scope(state: \.destination?.postWrite, action: \.destination.postWrite)
            ) { store in
                PostWriteView(store: store)
            }
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

private struct SearchedHeaderView: View {
    let searchText: String
    let count: Int
    
    var body: some View {
        Text(attributedTitle)
            .font(.pretendard(size: .body2, weight: .bold))
    }
    
    private var attributedTitle: AttributedString {
        var attributedString = AttributedString("\(searchText)(으)로 검색한 결과 (\(count))")
        attributedString.foregroundColor = .custom(.gray(.gray90))

        // 검색어 부분 찾기
        if let range = attributedString.range(of: searchText) {
            attributedString[range].foregroundColor = .custom(.brand(.deepSprout))
        }

        return attributedString
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        PostSearchResultView(
            store: Store(
                initialState: PostSearchResultFeature.State(
                    searchQuery: "김치찌개",
                    myUserId: nil
                )
            ) {
                PostSearchResultFeature()
            }
        )
    }
}
