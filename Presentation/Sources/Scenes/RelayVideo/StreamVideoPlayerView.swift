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
