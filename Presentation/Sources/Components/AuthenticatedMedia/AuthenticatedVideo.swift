//
//  AuthenticatedVideo.swift
//  Presentation
//
//  Created by 김영훈 on 1/7/26.
//

import SwiftUI
import AVKit
import AVFoundation
import Domain
import Data
import ComposableArchitecture

struct AuthenticatedVideo: View {
    private let videoPath: String?
    private let showsPlaybackControls: Bool

    @State private var videoURL: URL?
    @State private var headers: [String: String]?
    @State private var loadingFailed: Bool = false
    @State private var isLoading: Bool = true
    @State private var isPlaying: Bool = false
    @Dependency(\.imageService) var imageService

    init(
        videoPath: String?,
        showsPlaybackControls: Bool = true
    ) {
        self.videoPath = videoPath
        self.showsPlaybackControls = showsPlaybackControls
    }

    var body: some View {
        GeometryReader { geometry in
            Group {
                if videoPath == nil {
                    emptyPlaceholder(isSmall: isSmall(for: geometry.size))
                } else if loadingFailed {
                    errorPlaceholder(isSmall: isSmall(for: geometry.size))
                } else if let videoURL, let headers {
                    VideoPlayerView(
                        url: videoURL,
                        headers: headers,
                        showsPlaybackControls: showsPlaybackControls,
                        isPlaying: $isPlaying,
                        size: geometry.size
                    )
                } else if isLoading {
                    loadingPlaceholder
                }
            }
        }
        .task {
            await loadVideo()
        }
    }

    // MARK: - Private Methods

    private func loadVideo() async {
        guard let videoPath else {
            isLoading = false
            return
        }

        do {
            let request = try await imageService.makeAuthenticatedRequest(for: videoPath)
            if let url = request.url {
                videoURL = url
                headers = request.allHTTPHeaderFields
            }
            isLoading = false
        } catch {
            loadingFailed = true
            isLoading = false
        }
    }

    private func isSmall(for size: CGSize) -> Bool {
        min(size.width, size.height) < 120
    }

    // MARK: - Placeholder Views

    private var loadingPlaceholder: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.custom(.gray(.gray30)))
    }

    private func emptyPlaceholder(isSmall: Bool) -> some View {
        Group {
            if isSmall {
                AppIcon.video
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.custom(.gray(.gray45)))
                    .padding(AppPadding.medium.value)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.custom(.gray(.gray30)))
            } else {
                VStack(spacing: AppPadding.small.value) {
                    AppIcon.video
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(.custom(.gray(.gray45)))
                    Text("비디오가 없습니다")
                        .font(.pretendard(size: .body3, weight: .medium))
                        .foregroundStyle(.custom(.gray(.gray45)))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.custom(.gray(.gray30)))
            }
        }
    }

    private func errorPlaceholder(isSmall: Bool) -> some View {
        Group {
            if isSmall {
                AppIcon.exclamationMark
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.custom(.gray(.gray45)))
                    .padding(AppPadding.medium.value)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.custom(.gray(.gray30)))
            } else {
                VStack(spacing: AppPadding.small.value) {
                    AppIcon.exclamationMark
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(.custom(.gray(.gray45)))
                    
                    Text("비디오 로딩 실패")
                        .font(.pretendard(size: .body3, weight: .medium))
                        .foregroundStyle(.custom(.gray(.gray45)))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.custom(.gray(.gray30)))
            }
        }
    }
}

// MARK: - Play Button Overlay

private struct PlayButtonOverlay: View {
    let isSmall: Bool

    var body: some View {
        let circleSize: CGFloat = isSmall ? 32 : 64
        let iconSize: CGFloat = isSmall ? 24 : 48

        Circle()
            .fill(Color.black.opacity(0.6))
            .frame(width: circleSize, height: circleSize)
            .overlay(
                AppIcon.playCircle
                    .resizable()
                    .frame(width: iconSize, height: iconSize)
                    .foregroundStyle(.white)
            )
    }
}

// MARK: - UIKit Bridge

private struct VideoPlayerView: View {
    let url: URL
    let headers: [String: String]
    let showsPlaybackControls: Bool
    @Binding var isPlaying: Bool
    let size: CGSize
    @State private var player: AVPlayer?

    var body: some View {
        let isSmall = min(size.width, size.height) < 120

        ZStack {
            PlayerViewControllerWrapper(
                url: url,
                headers: headers,
                showsPlaybackControls: showsPlaybackControls,
                isPlaying: $isPlaying,
                player: $player
            )

            // 중앙 재생 버튼 (재생 중이 아닐 때만 표시)
            if !isPlaying {
                Button {
                    player?.play()
                } label: {
                    PlayButtonOverlay(isSmall: isSmall)
                }
            }
        }
    }
}

private struct PlayerViewControllerWrapper: UIViewControllerRepresentable {
    let url: URL
    let headers: [String: String]
    let showsPlaybackControls: Bool
    @Binding var isPlaying: Bool
    @Binding var player: AVPlayer?

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.showsPlaybackControls = showsPlaybackControls
        controller.videoGravity = .resizeAspect

        // Coordinator에서 player 생성 및 캐싱
        let newPlayer = context.coordinator.getOrCreatePlayer(for: url, headers: headers)
        controller.player = newPlayer

        // 최초 생성 시 player 바인딩 (한 번만)
        Task { @MainActor in
            player = newPlayer
        }

        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // URL이 변경되면 Coordinator에서 player 업데이트
        let currentURL = (uiViewController.player?.currentItem?.asset as? AVURLAsset)?.url

        if currentURL != url {
            let newPlayer = context.coordinator.getOrCreatePlayer(for: url, headers: headers)
            uiViewController.player = newPlayer

            // URL 변경 시에만 player 바인딩 업데이트
            Task { @MainActor in
                player = newPlayer
            }
        }

        // 컨트롤 설정 업데이트
        uiViewController.showsPlaybackControls = showsPlaybackControls

        // isPlaying binding 업데이트
        context.coordinator.isPlayingBinding = $isPlaying
    }

    func makeCoordinator() -> PlayerCoordinator {
        PlayerCoordinator(isPlaying: $isPlaying)
    }

    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: PlayerCoordinator) {
        // 뷰가 사라질 때 일시정지만 수행 (player는 Coordinator가 유지)
        uiViewController.player?.pause()
    }
}

// MARK: - Player Coordinator

private final class PlayerCoordinator: NSObject, @unchecked Sendable {
    // Player를 Coordinator에서 유지 (스크롤 시 재사용)
    private var player: AVPlayer?
    private var currentURL: URL?
    private var playbackObserver: NSKeyValueObservation?
    var isPlayingBinding: Binding<Bool>

    init(isPlaying: Binding<Bool>) {
        self.isPlayingBinding = isPlaying
        super.init()
    }

    func getOrCreatePlayer(for url: URL, headers: [String: String]) -> AVPlayer {
        // 같은 URL이면 기존 player 재사용
        if let player, currentURL == url {
            return player
        }

        // URL이 바뀌었거나 player가 없으면 새로 생성
        cleanupPlayer()

        // HTTP 헤더를 포함한 AVURLAsset 생성
        let options = ["AVURLAssetHTTPHeaderFieldsKey": headers]
        let asset = AVURLAsset(url: url, options: options)
        let playerItem = AVPlayerItem(asset: asset)

        // 버퍼 관리 최적화
        playerItem.preferredForwardBufferDuration = 3.0

        let newPlayer = AVPlayer(playerItem: playerItem)

        // 자동 재생 방지로 초기 로딩 최적화
        newPlayer.automaticallyWaitsToMinimizeStalling = true

        // 배터리 효율성을 위한 설정
        newPlayer.preventsDisplaySleepDuringVideoPlayback = false

        self.player = newPlayer
        self.currentURL = url

        // 재생 상태 관찰
        setupPlaybackObserver(for: newPlayer)

        return newPlayer
    }

    private func setupPlaybackObserver(for player: AVPlayer) {
        playbackObserver?.invalidate()

        playbackObserver = player.observe(\.timeControlStatus, options: [.new]) { [weak self] player, _ in
            Task { @MainActor in
                self?.isPlayingBinding.wrappedValue = (player.timeControlStatus == .playing)
            }
        }
    }

    private func cleanupPlayer() {
        playbackObserver?.invalidate()
        playbackObserver = nil
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil
    }

    deinit {
        cleanupPlayer()
    }
}
