//
//  RelayVideoView.swift
//  Presentation
//
//  Created by 김영훈 on 12/20/25.
//

import SwiftUI
import AVKit
import Domain
import ComposableArchitecture

struct RelayVideoView: View {
    let store: StoreOf<RelayVideoFeature>
    
    var body: some View {
        WithPerceptionTracking {
            @Perception.Bindable var store = store
            
            ZStack {
                Color.black.ignoresSafeArea()

                if store.videoList.isLoading && store.videoList.videoList.isEmpty {
                    LoadingView()
                } else if !store.videoList.videoList.isEmpty {
                    VideoContentView(store: store)
                } else {
                    EmptyVideoView()
                }
            }
            .overlay(alignment: .trailing) {
                if !store.videoList.videoList.isEmpty,
                   store.currentVideo != nil,
                   store.currentStream != nil {
                    ControlSection(store: store)
                        .padding(.trailing, .large)
                }
            }
            .overlay(alignment: .topLeading) {
                CloseButton(store: store)
                    .padding([.leading, .top], .large)
            }
            .onAppear {
                store.send(.onAppear)
            }
            .onDisappear {
                Task {
                    await PlayerPoolManager.shared.cleanupAll()
                }
            }
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }
}

// MARK: - Loading View
private struct LoadingView: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .custom(.gray(.gray0))))
    }
}

// MARK: - Empty View
private struct EmptyVideoView: View {
    var body: some View {
        Text("영상이 없습니다")
            .font(.pretendard(size: .body1, weight: .medium))
            .foregroundStyle(.custom(.gray(.gray0)))
    }
}

// MARK: - Video Content View
private struct VideoContentView: View {
    @Perception.Bindable var store: StoreOf<RelayVideoFeature>

    var body: some View {
        WithPerceptionTracking {
            GeometryReader { geometry in
                ScrollViewReader { proxy in
                    WithPerceptionTracking {
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack(spacing: 0) {
                                ForEach(Array(store.videoList.videoList.enumerated()), id: \.element.id) { index, video in
                                    WithPerceptionTracking {
                                        let stream = store.videoStream.stream(for: video.id)
                                        let isPlaying = index == store.videoList.currentIndex

                                        VideoPlayerCell(
                                            store: store,
                                            videoInfo: video,
                                            stream: stream,
                                            isPlaying: isPlaying
                                        )
                                        .frame(width: geometry.size.width, height: geometry.size.height)
                                        .id(index)
                                    }
                                }
                            }
                        }
                        .ignoresSafeArea()
                        .simultaneousGesture(SwipeGestureHandler(store: store))
                        .onChange(of: store.videoList.currentIndex) { newIndex in
                            withAnimation {
                                proxy.scrollTo(newIndex, anchor: .top)
                            }
                        }
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
}

// MARK: - Swipe Gesture Handler
private struct SwipeGestureHandler: Gesture {
    let store: StoreOf<RelayVideoFeature>
    
    var body: some Gesture {
        DragGesture()
            .onEnded { value in
                let threshold: CGFloat = 50
                if value.translation.height < -threshold {
                    let nextIndex = min(store.videoList.currentIndex + 1, store.videoList.videoList.count - 1)
                    store.send(.videoList(.scrollToIndex(nextIndex)))
                } else if value.translation.height > threshold {
                    let prevIndex = max(store.videoList.currentIndex - 1, 0)
                    store.send(.videoList(.scrollToIndex(prevIndex)))
                }
            }
    }
}

// MARK: - Control Section
private struct ControlSection: View {
    @Perception.Bindable var store: StoreOf<RelayVideoFeature>
    
    var body: some View {
        WithPerceptionTracking {
            HStack {
                Spacer()
                
                VStack(spacing: 40) {
                    LikeButton(store: store)
                    
                    SubtitleButton(store: store)
                    
                    QualityButton(store: store)
                }
            }
        }
    }
}

// MARK: - Like Button
private struct LikeButton: View {
    let store: StoreOf<RelayVideoFeature>
    
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: AppPadding.tiny.value) {
                HeartButton(
                    isLike: store.isCurrentVideoLiked,
                    nonLikeColor: .custom(.gray(.gray0)),
                    size: 32
                ) {
                    store.send(.toggleLike)
                }
                Text("좋아요")
                    .font(.pretendard(size: .caption1, weight: .regular))
                    .foregroundStyle(.white)
            }
        }
    }
}

// MARK: - Subtitle Button
private struct SubtitleButton: View {
    let store: StoreOf<RelayVideoFeature>
    @State private var showSubtitleMenu = false

    var body: some View {
        WithPerceptionTracking {
            let selectedSubtitle = store.selectedSubtitle
            let currentStream = store.currentStream

            Button {
                showSubtitleMenu = true
            } label: {
                VStack(spacing: AppPadding.tiny.value) {
                    if selectedSubtitle != nil {
                        AppIcon.captionsBubbleFill
                            .font(.system(size: 32))
                            .foregroundStyle(.custom(.brand(.blackSprout)))
                    } else { AppIcon.captionsBubbleEmpty
                            .font(.system(size: 32))
                            .foregroundStyle(.white)
                    }
                    
                    Text(selectedSubtitle?.name ?? "자막")
                        .font(.pretendard(size: .caption1, weight: .regular))
                        .foregroundStyle(.white)
                }
            }
            .confirmationDialog("자막 선택", isPresented: $showSubtitleMenu, titleVisibility: .hidden) {
                Button("자막 끄기") {
                    store.send(.subtitle(.selectSubtitle(nil)))
                }

                if let currentStream {
                    ForEach(currentStream.subtitles, id: \.language) { subtitle in
                        Button(subtitle.name) {
                            store.send(.subtitle(.selectSubtitle(subtitle)))
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Quality Button
private struct QualityButton: View {
    let store: StoreOf<RelayVideoFeature>
    @State private var showQualityMenu = false

    var body: some View {
        WithPerceptionTracking {
            let selectedQuality = store.selectedQuality
            let currentVideo = store.currentVideo

            Button {
                showQualityMenu = true
            } label: {
                VStack(spacing: AppPadding.tiny.value) {
                    AppIcon.gearshapeFill
                        .font(.system(size: 32))
                        .foregroundStyle(.white)
                    Text(selectedQuality == "auto" ? "자동" : selectedQuality)
                        .font(.pretendard(size: .caption1, weight: .regular))
                        .foregroundStyle(.white)
                }
            }
            .confirmationDialog("화질 선택", isPresented: $showQualityMenu, titleVisibility: .hidden) {
                Button("자동") {
                    store.send(.selectQuality("auto"))
                }

                if let currentVideo {
                    ForEach(currentVideo.availableQualities, id: \.self) { quality in
                        Button(quality) {
                            store.send(.selectQuality(quality))
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Video Player Cell
private struct VideoPlayerCell: View {
    @Perception.Bindable var store: StoreOf<RelayVideoFeature>
    let videoInfo: VideoResponse
    let stream: StreamResponse?
    let isPlaying: Bool

    @State private var player: AVPlayer?

    var body: some View {
        WithPerceptionTracking {
            Group {
                if let stream {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 60)

                        ZStack {
                            // 영상 플레이어
                            StreamVideoPlayerView(
                                stream: stream,
                                selectedQuality: store.selectedQuality,
                                isPlaying: isPlaying,
                                player: $player
                            )

                            // 자막 오버레이
                            if store.isSubtitleEnabled, !store.currentSubtitleText.isEmpty {
                                VStack {
                                    Spacer()
                                    Text(store.currentSubtitleText)
                                        .font(.pretendard(size: .body2, weight: .semiBold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, .medium)
                                        .padding(.vertical, .small)
                                        .background(Color.black.opacity(0.8))
                                        .cornerRadius(8)
                                        .padding(.bottom, .medium)
                                }
                            }
                        }

                        // 하단 비디오 정보 영역
                        HStack(alignment: .bottom) {
                            VStack(alignment: .leading, spacing: AppPadding.small.value) {
                                Text(videoInfo.title)
                                    .font(.pretendard(size: .body1, weight: .semiBold))
                                    .foregroundStyle(.white)
                                
                                Text(videoInfo.description)
                                    .font(.pretendard(size: .body2, weight: .regular))
                                    .foregroundStyle(.white.opacity(0.8))
                                    .lineLimit(2)
                                
                                HStack(spacing: AppPadding.medium.value) {
                                    HStack(spacing: AppPadding.tiny.value) {
                                        AppIcon.likeFill
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        
                                        Text("\(videoInfo.likeCount)")
                                            .font(.pretendard(size: .caption1, weight: .medium))
                                    }
                                    
                                    HStack(spacing: AppPadding.tiny.value) {
                                        AppIcon.views
                                            .resizable()
                                            .frame(width: 16, height: 12)
                                        
                                        Text("\(videoInfo.viewCount)")
                                            .font(.pretendard(size: .caption1, weight: .medium))
                                    }
                                }
                                .foregroundStyle(.white.opacity(0.8))
                            }
                            .padding(.horizontal, .medium)
                        }
                        .frame(height: 150)
                        .padding(.bottom, .xLarge)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.black.opacity(0), Color.black.opacity(0.8)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                } else {
                    // 스트림 로딩 중
                    VStack(spacing: AppPadding.medium.value) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        
                        Text("영상 로딩 중...")
                            .font(.pretendard(size: .body2, weight: .medium))
                            .foregroundStyle(.white)
                    }
                }
            }
            .task(id: isPlaying) {
                // isPlaying이 변경될 때마다 task 재시작
                await trackPlayerTime()
            }
        }
    }

    private func trackPlayerTime() async {
        while !Task.isCancelled {
            // 현재 재생중인 비디오가 아니면 추적하지 않음
            guard store.currentVideo?.id == videoInfo.id else {
                try? await Task.sleep(nanoseconds: 500_000_000)
                continue
            }

            guard let player else {
                try? await Task.sleep(nanoseconds: 500_000_000)
                continue
            }

            store.send(.updatePlayerTime(player.currentTime().seconds))
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
    }
}

// MARK: - Close Button
private struct CloseButton: View {
    let store: StoreOf<RelayVideoFeature>
    
    var body: some View {
        WithPerceptionTracking {
            Button {
                store.send(.closeButtonTapped)
            } label: {
                AppIcon.xmark
                    .resizable()
                    .fontWeight(.bold)
                    .frame(width: 12, height: 12)
                    .foregroundStyle(.custom(.gray(.gray0)))
                    .padding(.all, .small)
                    .background {
                        Circle()
                            .fill(.custom(.gray(.gray75)).opacity(0.8))
                    }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    RelayVideoView(
        store: Store(initialState: RelayVideoFeature.State()) {
            RelayVideoFeature()
        }
    )
}
