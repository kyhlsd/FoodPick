//
//  OtherProfileView.swift
//  Presentation
//
//  Created by 김영훈 on 1/6/26.
//

import SwiftUI
import Domain
import ComposableArchitecture

struct OtherProfileView: View {
    let store: StoreOf<OtherProfileFeature>

    var body: some View {
        WithPerceptionTracking {
            @Perception.Bindable var store = store

            ZStack {
                Color.custom(.gray(.gray15))
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppPadding.xLarge.value) {
                        // 프로필 이미지
                        ProfileImageSection(profileImage: store.profile.profileImage)

                        // 닉네임
                        Text(store.profile.nickname)
                            .font(.pretendard(size: .title1, weight: .bold))
                            .foregroundStyle(.custom(.gray(.gray90)))

                        // 채팅
                        PrimaryButton(
                            title: "채팅하기",
                            height: 40,
                            fontSize: .body1
                        ) {
                            
                        }
                        
                        MyDivider()

                        // 게시물 그리드
                        PostGridSection(posts: store.userPosts) { postId in
                            store.send(.postTapped(postId: postId))
                        }

                        Spacer(minLength: 110)
                    }
                    .padding([.horizontal, .top], .xLarge)
                }
            }
            .alert($store.scope(state: \.alert, action: \.alert))
            .navigationDestination(
                item: $store.scope(state: \.destination?.postDetail, action: \.destination.postDetail)
            ) { postDetailStore in
                PostDetailView(store: postDetailStore)
            }
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

// MARK: - Profile Image Section
private struct ProfileImageSection: View {
    let profileImage: String?

    var body: some View {
        AuthenticatedImage(imagePath: profileImage)
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(.custom(.gray(.gray30)), lineWidth: 2)
            )
    }
}

// MARK: - Post Grid Section
private struct PostGridSection: View {
    let posts: [Post]
    let onPostTapped: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppPadding.medium.value) {
            if posts.isEmpty {
                Text("게시물이 없습니다")
                    .font(.pretendard(size: .body2, weight: .medium))
                    .foregroundStyle(.custom(.gray(.gray60)))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 4),
                        GridItem(.flexible(), spacing: 4),
                        GridItem(.flexible(), spacing: 4)
                    ],
                    spacing: 4
                ) {
                    ForEach(posts, id: \.postId) { post in
                        AuthenticatedMedia(mediaPath: post.files.first, showsPlaybackControls: false)
                            .aspectRatio(1, contentMode: .fit)
                            .allowsHitTesting(false)  // 비디오 플레이어의 터치 비활성화
                            .overlay(
                                Color.clear
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        onPostTapped(post.postId)
                                    }
                            )
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        OtherProfileView(
            store: Store(
                initialState: OtherProfileFeature.State(
                    profile: Profile(
                        userId: "test",
                        nickname: "테스트유저",
                        profileImage: nil
                    )
                )
            ) {
                OtherProfileFeature()
            }
        )
    }
}
