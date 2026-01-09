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

                if store.isLoading && store.videoList.isEmpty {
                    LoadingView()
                } else if !store.videoList.isEmpty {
                    VideoContentView(store: store)
                    ControlOverlayView(store: store)
                } else {
                    EmptyView()
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
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
    }
}

// MARK: - Empty View
private struct EmptyView: View {
    var body: some View {
        Text("영상이 없습니다")
            .font(.pretendard(size: .body1, weight: .medium))
            .foregroundStyle(.white)
    }
}

// MARK: - Video Content View
private struct VideoContentView: View {
    let store: StoreOf<RelayVideoFeature>

    var body: some View {
        WithPerceptionTracking {
            GeometryReader { geometry in
                ScrollViewReader { proxy in
                    VideoScrollView(store: store, geometry: geometry)
                        .onChange(of: store.currentIndex) { newIndex in
                            withAnimation {
                                proxy.scrollTo(newIndex, anchor: .top)
                            }
                        }
                }
            }
        }
    }
}

// MARK: - Video Scroll View
private struct VideoScrollView: View {
    let store: StoreOf<RelayVideoFeature>
    let geometry: GeometryProxy

    var body: some View {
        WithPerceptionTracking {
            if #available(iOS 17.0, *) {
                VideoScrollViewModern(store: store, geometry: geometry)
            } else {
                VideoScrollViewLegacy(store: store, geometry: geometry)
            }
        }
    }
}

// MARK: - Video Scroll View Modern (iOS 17+)
@available(iOS 17.0, *)
private struct VideoScrollViewModern: View {
    let store: StoreOf<RelayVideoFeature>
    let geometry: GeometryProxy

    var body: some View {
        WithPerceptionTracking {
            ScrollView(.vertical, showsIndicators: false) {
                VideoListContent(store: store, geometry: geometry)
            }
            .scrollTargetBehavior(.paging)
            .simultaneousGesture(SwipeGestureHandler(store: store))
        }
    }
}

// MARK: - Video Scroll View Legacy (iOS 16)
private struct VideoScrollViewLegacy: View {
    let store: StoreOf<RelayVideoFeature>
    let geometry: GeometryProxy

    var body: some View {
        WithPerceptionTracking {
            ScrollView(.vertical, showsIndicators: false) {
                VideoListContent(store: store, geometry: geometry)
            }
            .simultaneousGesture(SwipeGestureHandler(store: store))
        }
    }
}

// MARK: - Video List Content
private struct VideoListContent: View {
    let store: StoreOf<RelayVideoFeature>
    let geometry: GeometryProxy

    var body: some View {
        WithPerceptionTracking {
            LazyVStack(spacing: 0) {
                ForEach(Array(store.videoList.enumerated()), id: \.element.id) { index, video in
                    VideoPlayerCell(
                        videoInfo: video,
                        stream: store.loadedStreams[video.id],
                        isPlaying: index == store.currentIndex,
                        selectedQuality: store.selectedQuality,
                        isSubtitleEnabled: store.isSubtitleEnabled,
                        selectedSubtitle: store.selectedSubtitle
                    )
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .id(index)
                }
            }
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
                    let nextIndex = min(store.currentIndex + 1, store.videoList.count - 1)
                    store.send(.scrollToIndex(nextIndex))
                } else if value.translation.height > threshold {
                    let prevIndex = max(store.currentIndex - 1, 0)
                    store.send(.scrollToIndex(prevIndex))
                }
            }
    }
}

// MARK: - Control Overlay View
private struct ControlOverlayView: View {
    let store: StoreOf<RelayVideoFeature>

    var body: some View {
        WithPerceptionTracking {
            VStack {
                Spacer()
                HStack(alignment: .bottom, spacing: AppPadding.large.value) {
                    Spacer()
                    VStack(spacing: AppPadding.large.value) {
                        LikeButton(store: store)
                        SubtitleButton(store: store)
                        QualityButton(store: store)
                    }
                    .padding(.trailing, .large)
                }
                .padding(.bottom, .xLarge)
            }
        }
    }
}

// MARK: - Like Button
private struct LikeButton: View {
    let store: StoreOf<RelayVideoFeature>

    var body: some View {
        WithPerceptionTracking {
            Button {
                store.send(.toggleLike)
            } label: {
                VStack(spacing: AppPadding.tiny.value) {
                    Image(systemName: store.isCurrentVideoLiked ? "heart.fill" : "heart")
                        .font(.system(size: 32))
                        .foregroundStyle(store.isCurrentVideoLiked ? .red : .white)
                    Text("좋아요")
                        .font(.pretendard(size: .caption1, weight: .regular))
                        .foregroundStyle(.white)
                }
            }
        }
    }
}

// MARK: - Subtitle Button
private struct SubtitleButton: View {
    let store: StoreOf<RelayVideoFeature>

    var body: some View {
        WithPerceptionTracking {
            Button {
                store.send(.toggleSubtitle)
            } label: {
                VStack(spacing: AppPadding.tiny.value) {
                    Image(systemName: store.isSubtitleEnabled ? "captions.bubble.fill" : "captions.bubble")
                        .font(.system(size: 32))
                        .foregroundStyle(store.isSubtitleEnabled ? .custom(.brand(.blackSprout)) : .white)
                    Text("자막")
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
    let videoInfo: VideoResponse
    let stream: StreamResponse?
    let isPlaying: Bool
    let selectedQuality: String
    let isSubtitleEnabled: Bool
    let selectedSubtitle: Subtitle?

    @State private var player: AVPlayer?
    @State private var subtitleText: String = ""
    @Dependency(\.fileService) var fileService

    var body: some View {
        ZStack {
            if let stream = stream {
                StreamVideoPlayerView(
                    stream: stream,
                    selectedQuality: selectedQuality,
                    isPlaying: isPlaying,
                    player: $player
                )

                // 비디오 정보 오버레이 (왼쪽 하단)
                VStack {
                    Spacer()

                    HStack {
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
                        .padding(.leading, .large)

                        Spacer()
                    }
                    .padding(.bottom, 120)
                }

                // 자막 오버레이
                if isSubtitleEnabled, !subtitleText.isEmpty {
                    VStack {
                        Spacer()
                        Text(subtitleText)
                            .font(.pretendard(size: .body2, weight: .semiBold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, .medium)
                            .padding(.vertical, .small)
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(8)
                            .padding(.bottom, 220)
                    }
                }
            } else if stream == nil {
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
            // 자막 로드
            if isSubtitleEnabled, let subtitle = selectedSubtitle {
                await loadSubtitle(subtitle)
            }
        }
        .onChange(of: isSubtitleEnabled) { newValue in
            if newValue, let subtitle = selectedSubtitle {
                Task {
                    await loadSubtitle(subtitle)
                }
            } else {
                subtitleText = ""
            }
        }
        .onChange(of: selectedSubtitle) { newSubtitle in
            if isSubtitleEnabled, let subtitle = newSubtitle {
                Task {
                    await loadSubtitle(subtitle)
                }
            }
        }
    }

    private func loadSubtitle(_ subtitle: Subtitle) async {
        do {
            // FileService를 사용하여 자막 파일 다운로드 (Authorization, SeSACKey 헤더 필요)
            let request = try await fileService.makeAuthenticatedRequest(for: subtitle.url)
            let (data, _) = try await URLSession.shared.data(for: request)

            if let subtitleContent = String(data: data, encoding: .utf8) {
                // TODO: 실시간 자막 동기화 구현
                // 현재는 간단히 자막이 로드되었다는 표시만
                await MainActor.run {
                    subtitleText = "[\(subtitle.name)]"
                }
            }
        } catch {
            print("Failed to load subtitle: \(error)")
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
        DispatchQueue.main.async {
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

            DispatchQueue.main.async {
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
