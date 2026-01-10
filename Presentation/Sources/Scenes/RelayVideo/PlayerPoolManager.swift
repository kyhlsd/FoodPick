//
//  PlayerPoolManager.swift
//  Presentation
//
//  Created by 김영훈 on 1/11/26.
//

import AVKit
import Foundation

actor PlayerPoolManager {
    static let shared = PlayerPoolManager()

    private let maxPoolSize = 5
    private var playerPool: [PooledPlayer] = []

    private init() {}

    // 풀링된 플레이어 정보
    private struct PooledPlayer {
        let player: AVPlayer
        var currentURL: URL?
        var lastUsedTime: Date
        var isActive: Bool
    }

    // URL에 해당하는 플레이어를 가져오거나 생성
    func getPlayer(for url: URL) -> AVPlayer {
        // 1. 같은 URL을 재생 중인 플레이어가 있으면 재사용
        if let index = playerPool.firstIndex(where: { $0.currentURL == url }) {
            let player = playerPool[index].player
            
            configurePlayer(player, isPreload: false)
            if let item = player.currentItem {
                configurePlayerItem(item, isPreload: false)
            }
            
            playerPool[index].lastUsedTime = Date()
            playerPool[index].isActive = true
            return player
        }

        // 2. 비활성 플레이어가 있으면 재사용
        if let index = playerPool.firstIndex(where: { !$0.isActive }) {
            let player = playerPool[index].player
            replacePlayerItem(player: player, url: url)
            playerPool[index] = PooledPlayer(
                player: player,
                currentURL: url,
                lastUsedTime: Date(),
                isActive: true
            )
            return player
        }

        // 3. 풀이 가득 차지 않았으면 새 플레이어 생성
        if playerPool.count < maxPoolSize {
            let player = createNewPlayer(url: url)
            playerPool.append(PooledPlayer(
                player: player,
                currentURL: url,
                lastUsedTime: Date(),
                isActive: true
            ))
            return player
        }

        // 4. 풀이 가득 찬 경우, 가장 오래된 비활성 플레이어 재사용
        let oldestIndex = playerPool.indices
            .min { playerPool[$0].lastUsedTime < playerPool[$1].lastUsedTime } ?? 0

        let player = playerPool[oldestIndex].player
        replacePlayerItem(player: player, url: url)
        playerPool[oldestIndex] = PooledPlayer(
            player: player,
            currentURL: url,
            lastUsedTime: Date(),
            isActive: true
        )
        return player
    }

    // 플레이어를 비활성화
    func deactivatePlayer(for url: URL) {
        if let index = playerPool.firstIndex(where: { $0.currentURL == url }) {
            playerPool[index].isActive = false
            playerPool[index].player.pause()
        }
    }

    // 특정 URL의 플레이어 아이템 미리 로드
    func preloadPlayer(for url: URL) {
        // 이미 로드되어 있으면 스킵
        if playerPool.contains(where: { $0.currentURL == url }) {
            return
        }

        // 비활성 플레이어가 있으면 미리 로드
        if let index = playerPool.firstIndex(where: { !$0.isActive }) {
            let player = playerPool[index].player
            replacePlayerItem(player: player, url: url, isPreload: true)
            playerPool[index] = PooledPlayer(
                player: player,
                currentURL: url,
                lastUsedTime: Date(),
                isActive: false  // 아직 활성화하지 않음
            )
            return
        }

        // 풀이 가득 차지 않았으면 새 플레이어 생성
        if playerPool.count < maxPoolSize {
            let player = createNewPlayer(url: url)
            playerPool.append(PooledPlayer(
                player: player,
                currentURL: url,
                lastUsedTime: Date(),
                isActive: false  // 아직 활성화하지 않음
            ))
            return
        }
    }

    // 모든 플레이어 정리
    func cleanupAll() {
        for pooledPlayer in playerPool {
            pooledPlayer.player.pause()
            pooledPlayer.player.replaceCurrentItem(with: nil)
        }
        playerPool.removeAll()
    }

    // MARK: - Private Helpers

    private func createNewPlayer(url: URL, isPreload: Bool = false) -> AVPlayer {
        let playerItem = AVPlayerItem(url: url)
            configurePlayerItem(playerItem, isPreload: isPreload)

            let player = AVPlayer(playerItem: playerItem)
            configurePlayer(player, isPreload: isPreload)

            return player
    }

    private func replacePlayerItem(player: AVPlayer, url: URL, isPreload: Bool = false) {
        player.pause()
        let newItem = AVPlayerItem(url: url)
        configurePlayerItem(newItem, isPreload: isPreload)
        configurePlayer(player, isPreload: isPreload)
        player.replaceCurrentItem(with: newItem)
    }

    private func configurePlayerItem(_ item: AVPlayerItem, isPreload: Bool = false) {
        if isPreload {
            // Preload용: 최소한의 버퍼만 준비
            item.preferredForwardBufferDuration = 2.0  // 2초만 버퍼링
            item.preferredPeakBitRate = 1_000_000  // 낮은 품질로 초기 로드 (1Mbps)
        } else {
            // 활성 재생용: 정상 버퍼
            item.preferredForwardBufferDuration = 5.0  // 5초 버퍼
            item.preferredPeakBitRate = 0  // 최고 품질 사용
        }
    }

    private func configurePlayer(_ player: AVPlayer, isPreload: Bool = false) {
        if isPreload {
            // Preload용: 대역폭 절약 모드
            player.automaticallyWaitsToMinimizeStalling = false  // 버퍼링 대기 안함
            player.preventsDisplaySleepDuringVideoPlayback = false
        } else {
            // 활성 재생용: 최적화 모드
            player.automaticallyWaitsToMinimizeStalling = true
            player.preventsDisplaySleepDuringVideoPlayback = true
        }

        player.actionAtItemEnd = .pause

        // 오디오 세션 설정
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
    }
}
