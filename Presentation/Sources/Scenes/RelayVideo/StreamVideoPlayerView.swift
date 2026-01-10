//
//  StreamVideoPlayerView.swift
//  Presentation
//
//  Created by 김영훈 on 1/10/26.
//

import SwiftUI
import AVKit
import Domain
import ComposableArchitecture

struct StreamVideoPlayerView: View {
    let stream: StreamResponse
    let selectedQuality: String
    let isPlaying: Bool
    @Binding var player: AVPlayer?
    @Dependency(\.fileService) var fileService

    var body: some View {
        if let url = videoURL {
            PooledPlayerView(
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

// MARK: - Pooled Player View
private struct PooledPlayerView: UIViewRepresentable {
    let url: URL
    let isPlaying: Bool
    @Binding var player: AVPlayer?

    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView()

        // PlayerPoolManager에서 player 가져오기
        Task { @MainActor in
            let pooledPlayer = await PlayerPoolManager.shared.getPlayer(for: url)
            view.player = pooledPlayer
            player = pooledPlayer

            // 재생 상태 적용
            if isPlaying {
                pooledPlayer.play()
            }
        }

        return view
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        let currentURL = (uiView.player?.currentItem?.asset as? AVURLAsset)?.url
        // URL이 변경되면 풀에서 새 player 가져오기
        if currentURL != url {
            Task { @MainActor in
                // 기존 URL을 비활성화
                if let oldURL = currentURL {
                    await PlayerPoolManager.shared.deactivatePlayer(for: oldURL)
                }

                // 새 player 가져오기
                let pooledPlayer = await PlayerPoolManager.shared.getPlayer(for: url)
                uiView.player = pooledPlayer
                player = pooledPlayer

                if isPlaying {
                    pooledPlayer.play()
                }
            }
        } else {
            // 같은 URL이면 재생 상태만 동기화
            if isPlaying {
                uiView.player?.play()
            } else {
                uiView.player?.pause()
            }
        }
    }

    func makeCoordinator() -> PooledPlayerCoordinator {
        PooledPlayerCoordinator(url: url)
    }

    static func dismantleUIView(_ uiView: PlayerUIView, coordinator: PooledPlayerCoordinator) {
        uiView.player?.pause()

        // 비활성화 (풀에 반환)
        Task {
            await PlayerPoolManager.shared.deactivatePlayer(for: coordinator.url)
        }
    }
}

// MARK: - Player UIView
private final class PlayerUIView: UIView {
    private var playerLayer: AVPlayerLayer?

    var player: AVPlayer? {
        didSet {
            if let playerLayer = playerLayer {
                playerLayer.player = player
            } else {
                setupPlayerLayer()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPlayerLayer() {
        guard let player = player else { return }

        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspectFill
        layer.frame = bounds
        self.layer.addSublayer(layer)
        self.playerLayer = layer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
}

// MARK: - Pooled Player Coordinator
private final class PooledPlayerCoordinator: NSObject {
    let url: URL

    init(url: URL) {
        self.url = url
        super.init()
    }
}
