//
//  CommunityView.swift
//  Presentation
//
//  Created by 김영훈 on 1/3/26.
//

import SwiftUI
import Domain
import ComposableArchitecture

struct CommunityView: View {
    let store: StoreOf<CommunityFeature>

    var body: some View {
        WithPerceptionTracking {
            @Perception.Bindable var store = store

            let posts = store.posts
            let isLoading = store.isLoading
            let isLoadingMore = store.isLoadingMore
            let canLoadMore = store.canLoadMore
            let orderBy = store.orderBy
            let isShowingOrderByMenu = store.isShowingOrderByMenu
            let selectedDistanceIndex = store.selectedDistanceIndex

            ZStack {
                Color.custom(.gray(.gray15))
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppPadding.xLarge.value) {
                        HStack(spacing: AppPadding.medium.value) {
                            MySearchBar(
                                text: $store.searchText.sending(\.searchTextChanged)
                            ) {
                                store.send(.searchSubmitted)
                            }
                            
                            Button {
                                
                            } label: {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.custom(.brand(.deepSprout)))
                                    .overlay(
                                        AppIcon.write
                                            .resizable()
                                            .frame(width: 28, height: 28)
                                            .foregroundStyle(.custom(.gray(.gray0)))
                                    )
                                    .frame(width: 40, height: 40)
                            }
                        }
                        .padding(.horizontal, .xLarge)

                        DistanceSelector(
                            selectedIndex: selectedDistanceIndex
                        ) {
                            store.send(.distanceChanged($0))
                        }
                        .padding(.horizontal, .xLarge)

                        HStack {
                            Text("타임 라인")
                                .font(.pretendard(size: .body2, weight: .bold))
                                .foregroundStyle(.custom(.gray(.gray90)))

                            Spacer()

                            DropdownMenu(
                                options: PostOrderBy.allCases,
                                selectedOption: orderBy,
                                isOpen: isShowingOrderByMenu,
                                onToggle: { store.send(.toggleOrderByMenu) },
                                onSelect: { store.send(.orderByChanged($0)) },
                                label: { option in
                                    HStack(spacing: AppPadding.tiny.value) {
                                        AppIcon.list
                                            .resizable()
                                            .frame(width: 12, height: 12)
                                            .foregroundStyle(.custom(.brand(.blackSprout)))
                                        
                                        Text(option.rawValue)
                                            .font(.pretendard(size: .caption1, weight: .semiBold))
                                            .foregroundStyle(.custom(.brand(.blackSprout)))
                                    }
                                }
                            )
                        }
                        .padding(.horizontal, .xLarge)
                        .dropdownHost(isOpen: isShowingOrderByMenu) {
                            store.send(.toggleOrderByMenu)
                        }

                        // 배너
                        BannerListView(
                            store: store.scope(state: \.banner, action: \.banner)
                        )

                        // 포스트 리스트
                        PostListView(
                            posts: posts,
                            isLoading: isLoading,
                            isLoadingMore: isLoadingMore,
                            canLoadMore: canLoadMore,
                            onLoadMore: {
                                store.send(.loadMore)
                            },
                            onLikePostTapped: { postId in
                                store.send(.likePostTapped(postId: postId))
                            }
                        )
                        .padding(.horizontal, .xLarge)

                        // 탭바가 가리지 않도록 추가
                        Rectangle()
                            .fill(.clear)
                            .frame(height: 110)
                    }
                    .padding(.top, .xLarge)
                }
                .ignoresSafeArea(edges: .bottom)
            }
            .dropdownBackdrop(isOpen: isShowingOrderByMenu) {
                store.send(.toggleOrderByMenu)
            }
            .hideKeyboardOnTap()
            .alert($store.scope(state: \.alert, action: \.alert))
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

private struct DistanceSelector: View {
    let selectedIndex: Int
    let onIndexChanged: (Int) -> Void
    @State private var tempIndex: Int?
    private let totalCount = 15

    var body: some View {
        let displayIndex = tempIndex ?? selectedIndex

        HStack(spacing: 0) {
            Text("Distance")
                .font(.pretendard(size: .body3, weight: .bold))
                .foregroundStyle(.custom(.brand(.deepSprout)))
                .padding(.vertical, .tiny)
                .padding(.horizontal, .small)
                .background(.custom(.brand(.brightSprout)))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(.custom(.brand(.deepSprout)), lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            
            Spacer()
            
            GeometryReader { proxy in
                let width = proxy.size.width
                let stepWidth = width / CGFloat(totalCount)
                
                ZStack(alignment: .topLeading) {
                    HStack(spacing: 0) {
                        ForEach(0..<totalCount, id: \.self) { index in
                            Capsule()
                                .fill(index == displayIndex
                                      ? .custom(.brand(.blackSprout))
                                      : index < displayIndex
                                      ? .custom(.brand(.deepSprout))
                                      : .custom(.gray(.gray30))
                                )
                                .frame(width: 8, height: 20)
                            if index < totalCount - 1 { Spacer() }
                        }
                    }
                    
                    Text("\(displayIndex + 1)")
                        .font(.pretendard(size: .caption2, weight: .semiBold))
                        .foregroundStyle(.custom(.gray(.gray0)))
                        .padding(.vertical, .tiny)
                        .padding(.horizontal, .small)
                        .background(Capsule().fill(.custom(.brand(.blackSprout))))
                        .position(
                            x: (CGFloat(displayIndex) * stepWidth) + (stepWidth / 2),
                            y: -12
                        )
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            calculateIndex(location: value.location, width: width)
                        }
                        .onEnded { _ in
                            if let finalIndex = tempIndex {
                                onIndexChanged(finalIndex)
                            }
                            tempIndex = nil
                        }
                )
            }
        }
        .padding(.all, .medium)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.custom(.gray(.gray0)))
        )
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.custom(.gray(.gray45)), lineWidth: 1)
        )
        .frame(maxWidth: .infinity)
    }

    private func calculateIndex(location: CGPoint, width: CGFloat) {
        let stepWidth = width / CGFloat(totalCount)
        let clampedIndex = min(max(0, Int(location.x / stepWidth)), totalCount - 1)
        if tempIndex != clampedIndex {
            withAnimation(.interactiveSpring(response: 0.15, dampingFraction: 0.8)) {
                tempIndex = clampedIndex
            }
        }
    }
}

// MARK: - Post List View
private struct PostListView: View {
    let posts: [Post]
    let isLoading: Bool
    let isLoadingMore: Bool
    let canLoadMore: Bool
    let onLoadMore: () -> Void
    let onLikePostTapped: (String) -> Void

    var body: some View {
        VStack(spacing: AppPadding.medium.value) {
            if isLoading && posts.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
            } else if posts.isEmpty {
                VStack(spacing: AppPadding.medium.value) {
                    Text("포스트가 없습니다")
                        .font(.pretendard(size: .body2, weight: .medium))
                        .foregroundStyle(.custom(.gray(.gray60)))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            } else {
                LazyVStack(spacing: AppPadding.medium.value) {
                    ForEach(Array(posts.enumerated()), id: \.element.postId) { index, post in
                        PostItemView(
                            post: post,
                            onLikePostTapped: onLikePostTapped
                        )
                        .onAppear {
                            if index == posts.count - 1 && canLoadMore {
                                onLoadMore()
                            }
                        }
                    }

                    if isLoadingMore {
                        ProgressView()
                            .padding(.vertical, .large)
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    CommunityView(
        store: Store(
            initialState: CommunityFeature.State(
                posts: [
                    Post(
                        postId: "1",
                        category: "맛집",
                        title: "여기 김치찌개 진짜 맛있어요!",
                        content: "점심에 들렀는데 김치찌개가 진짜 맛있더라구요. 김치도 직접 담그신다고 하시고 국물이 깊고 진해요. 다음에 또 올 것 같아요!",
                        restaurant: Restaurant(
                            restaurantId: "1",
                            category: .korean,
                            name: "맛있는 한식당",
                            close: "22:00",
                            restaurantImageURLs: [],
                            isPicchelin: false,
                            isPick: true,
                            pickCount: 42,
                            hashTags: ["한식", "김치찌개", "맛집"],
                            totalRating: 4.5,
                            totalOrderCount: 128,
                            totalReviewCount: 15,
                            geolocation: Geolocation(longitude: 127.0, latitude: 37.0),
                            distance: 0.5,
                            createdAt: Date(),
                            updatedAt: Date()
                        ),
                        geolocation: Geolocation(longitude: 127.0, latitude: 37.0),
                        creator: Profile(
                            userId: "user1",
                            nickname: "맛집탐험가",
                            profileImage: nil
                        ),
                        files: [
                            "/images/post1_1.jpg",
                            "/images/post1_2.jpg",
                            "/images/post1_3.jpg"
                        ],
                        isLike: true,
                        likeCount: 24,
                        createdAt: Date().addingTimeInterval(-3600),
                        updatedAt: Date().addingTimeInterval(-3600)
                    ),
                    Post(
                        postId: "2",
                        category: "후기",
                        title: "분위기 좋은 카페 발견!",
                        content: "친구랑 수다 떨기 좋은 카페예요. 아메리카노도 맛있고 디저트도 다양해요. 사진 찍기도 좋아요!",
                        restaurant: Restaurant(
                            restaurantId: "2",
                            category: .cafe,
                            name: "예쁜 카페",
                            close: "23:00",
                            restaurantImageURLs: ["/images/cafe.jpg"],
                            isPicchelin: true,
                            isPick: false,
                            pickCount: 128,
                            hashTags: ["카페", "디저트", "분위기"],
                            totalRating: 4.8,
                            totalOrderCount: 256,
                            totalReviewCount: 45,
                            geolocation: Geolocation(longitude: 127.1, latitude: 37.1),
                            distance: 1.2,
                            createdAt: Date(),
                            updatedAt: Date()
                        ),
                        geolocation: Geolocation(longitude: 127.1, latitude: 37.1),
                        creator: Profile(
                            userId: "user2",
                            nickname: "카페러버",
                            profileImage: nil
                        ),
                        files: [
                            "/images/post2_1.jpg",
                            "/images/post2_2.jpg"
                        ],
                        isLike: false,
                        likeCount: 15,
                        createdAt: Date().addingTimeInterval(-7200),
                        updatedAt: Date().addingTimeInterval(-7200)
                    ),
                    Post(
                        postId: "3",
                        category: "추천",
                        title: "피자 맛집 공유해요",
                        content: "여기 피자 진짜 맛있어요! 도우가 얇고 바삭하고 토핑도 신선해요. 가격도 합리적이고 양도 많아요.",
                        restaurant: Restaurant(
                            restaurantId: "3",
                            category: .pizza,
                            name: "맛있는 피자집",
                            close: "22:30",
                            restaurantImageURLs: ["/images/pizza.jpg"],
                            isPicchelin: false,
                            isPick: true,
                            pickCount: 67,
                            hashTags: ["피자", "이탈리안", "맛집"],
                            totalRating: 4.3,
                            totalOrderCount: 89,
                            totalReviewCount: 28,
                            geolocation: Geolocation(longitude: 126.9, latitude: 37.2),
                            distance: 2.1,
                            createdAt: Date(),
                            updatedAt: Date()
                        ),
                        geolocation: Geolocation(longitude: 126.9, latitude: 37.2),
                        creator: Profile(
                            userId: "user3",
                            nickname: "피자조아",
                            profileImage: nil
                        ),
                        files: [
                            "/images/post3_1.jpg"
                        ],
                        isLike: true,
                        likeCount: 38,
                        createdAt: Date().addingTimeInterval(-86400),
                        updatedAt: Date().addingTimeInterval(-86400)
                    )
                ]
            )
        ) {
            CommunityFeature()
        }
    )
}
