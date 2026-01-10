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
            
            ZStack(alignment: .center) {
                Color.black.ignoresSafeArea()
                
                if store.videoList.isLoading && store.videoList.videoList.isEmpty {
                    LoadingView()
                } else if !store.videoList.videoList.isEmpty {
                    VideoContentView(store: store)

                    if store.currentVideo != nil,
                       store.currentStream != nil {
                        ControlSection(store: store)
                            .padding(.trailing, .large)
                    }
                } else {
                    EmptyVideoView()
                }
            }
            .onAppear {
                store.send(.onAppear)
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

    var body: some View {
        WithPerceptionTracking {
            Menu {
                WithPerceptionTracking {
                    Button {
                        store.send(.subtitle(.selectSubtitle(nil)))
                    } label: {
                        HStack {
                            Text("자막 끄기")
                            if store.selectedSubtitle == nil {
                                Image(systemName: "checkmark")
                            }
                        }
                    }

                    if let currentStream = store.currentStream {
                        ForEach(currentStream.subtitles, id: \.language) { subtitle in
                            Button {
                                store.send(.subtitle(.selectSubtitle(subtitle)))
                            } label: {
                                HStack {
                                    Text(subtitle.name)
                                    if store.selectedSubtitle?.language == subtitle.language {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    }
                }
            } label: {
                VStack(spacing: AppPadding.tiny.value) {
                    Image(systemName: store.selectedSubtitle != nil ? "captions.bubble.fill" : "captions.bubble")
                        .font(.system(size: 32))
                        .foregroundStyle(store.selectedSubtitle != nil ? .custom(.brand(.blackSprout)) : .white)
                    Text(store.selectedSubtitle?.name ?? "자막")
                        .font(.pretendard(size: .caption1, weight: .regular))
                        .foregroundStyle(.white)
                }
            }
        }
    }
}

// MARK: - Quality Button
private struct QualityButton: View {
    let store: StoreOf<RelayVideoFeature>
    
    var body: some View {
        WithPerceptionTracking {
            Menu {
                Button {
                    store.send(.selectQuality("auto"))
                } label: {
                    HStack {
                        Text("자동")
                        if store.selectedQuality == "auto" {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                
                if let currentVideo = store.currentVideo {
                    ForEach(currentVideo.availableQualities, id: \.self) { quality in
                        Button {
                            store.send(.selectQuality(quality))
                        } label: {
                            HStack {
                                Text(quality)
                                if store.selectedQuality == quality {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
            } label: {
                VStack(spacing: AppPadding.tiny.value) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.white)
                    Text(store.selectedQuality == "auto" ? "자동" : store.selectedQuality)
                        .font(.pretendard(size: .caption1, weight: .regular))
                        .foregroundStyle(.white)
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
                                        Image(systemName: "heart.fill")
                                            .font(.system(size: 14))
                                        Text("\(videoInfo.likeCount)")
                                            .font(.pretendard(size: .caption1, weight: .medium))
                                    }
                                    
                                    HStack(spacing: AppPadding.tiny.value) {
                                        Image(systemName: "eye.fill")
                                            .font(.system(size: 14))
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
            .task {
                // 플레이어 시간 추적 시작
                await trackPlayerTime()
            }
        }
    }

    private func trackPlayerTime() async {
        while !Task.isCancelled {
            guard let player = player else {
                try? await Task.sleep(nanoseconds: 100_000_000)
                continue
            }

            let currentTime = player.currentTime().seconds
            store.send(.updatePlayerTime(currentTime))

            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1초마다 체크
        }
    }
}

// MARK: - Stream Video Player View
private struct StreamVideoPlayerView: View {
    let stream: StreamResponse
    let selectedQuality: String
    let isPlaying: Bool
    @Binding var player: AVPlayer?
    @Dependency(\.fileService) var fileService
    
    var body: some View {
        if let url = videoURL {
            PlayerViewControllerWrapper(
                url: url,
                isPlaying: isPlaying,
                player: $player
            )
        }
    }
    
    private var videoURL: URL? {
        let path: String
        if selectedQuality == "auto" {
            path = stream.streamURL
        } else if let quality = stream.qualities.first(where: { $0.quality == selectedQuality }) {
            path = quality.url
        } else {
            // 선택된 화질이 없으면 기본 스트림 URL 사용
            path = stream.streamURL
        }
        return try? fileService.makeFullURL(from: path)
    }
}

// MARK: - UIKit Player Wrapper
private struct PlayerViewControllerWrapper: UIViewControllerRepresentable {
    let url: URL
    let isPlaying: Bool
    @Binding var player: AVPlayer?
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
        
        // Coordinator에서 player 생성 및 캐싱
        let newPlayer = context.coordinator.getOrCreatePlayer(for: url)
        controller.player = newPlayer
        
        // 최초 생성 시 player 바인딩
        Task { @MainActor in
            player = newPlayer
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        let currentURL = (uiViewController.player?.currentItem?.asset as? AVURLAsset)?.url
        
        // URL이 변경되면 새 player 생성
        if currentURL != url {
            let newPlayer = context.coordinator.getOrCreatePlayer(for: url)
            uiViewController.player = newPlayer
            
            Task { @MainActor in
                player = newPlayer
            }
        }
        
        // 재생 상태 동기화
        if isPlaying {
            uiViewController.player?.play()
        } else {
            uiViewController.player?.pause()
        }
    }
    
    func makeCoordinator() -> StreamPlayerCoordinator {
        StreamPlayerCoordinator()
    }
    
    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: StreamPlayerCoordinator) {
        uiViewController.player?.pause()
    }
}

// MARK: - Stream Player Coordinator
private final class StreamPlayerCoordinator: NSObject {
    private var player: AVPlayer?
    private var currentURL: URL?
    
    func getOrCreatePlayer(for url: URL) -> AVPlayer {
        // 같은 URL이면 기존 player 재사용
        if let player, currentURL == url {
            return player
        }
        
        // URL이 바뀌었거나 player가 없으면 새로 생성
        cleanupPlayer()
        
        // 스트리밍 URL은 토큰이 포함되어 있어 별도 헤더 불필요
        let playerItem = AVPlayerItem(url: url)
        
        // 버퍼 관리 최적화
        playerItem.preferredForwardBufferDuration = 3.0
        
        let newPlayer = AVPlayer(playerItem: playerItem)
        
        // 최적화 설정
        newPlayer.automaticallyWaitsToMinimizeStalling = true
        newPlayer.preventsDisplaySleepDuringVideoPlayback = true
        newPlayer.actionAtItemEnd = .pause
        
        self.player = newPlayer
        self.currentURL = url
        
        return newPlayer
    }
    
    private func cleanupPlayer() {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil
    }
    
    deinit {
        cleanupPlayer()
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
