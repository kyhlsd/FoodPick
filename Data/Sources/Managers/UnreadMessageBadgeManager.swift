//
//  UnreadMessageBadgeManager.swift
//  Data
//
//  Created by 김영훈 on 1/12/26.
//

import Foundation
import UserNotifications

public actor UnreadMessageBadgeManager {
    public static let shared = UnreadMessageBadgeManager()
    private init() {}

    private let unreadCountsKey = "unreadMessageCounts"

    // 읽지 않은 메시지 수 증가
    public func incrementUnreadCount(for roomId: String) {
        var counts = getUnreadCounts()
        counts[roomId, default: 0] += 1
        saveUnreadCounts(counts)
        Task {
            await updateBadge()
        }
    }

    // 특정 채팅방의 읽지 않은 메시지 수 초기화
    public func clearUnreadCount(for roomId: String) {
        var counts = getUnreadCounts()
        counts.removeValue(forKey: roomId)
        saveUnreadCounts(counts)
        Task {
            await updateBadge()
        }
    }

    // 모든 읽지 않은 메시지 수 초기화
    public func clearAllUnreadCounts() {
        UserDefaults.standard.removeObject(forKey: unreadCountsKey)
        Task {
            await updateBadge()
        }
    }

    // 특정 채팅방의 읽지 않은 메시지 수 가져오기
    public func getUnreadCount(for roomId: String) -> Int {
        let counts = getUnreadCounts()
        return counts[roomId] ?? 0
    }

    // 전체 읽지 않은 메시지 수 가져오기
    public func getTotalUnreadCount() -> Int {
        let counts = getUnreadCounts()
        return counts.values.reduce(0, +)
    }

    // 모든 채팅방 ID 가져오기
    public func getAllRoomIds() -> [String] {
        let counts = getUnreadCounts()
        return Array(counts.keys)
    }

    // MARK: - Private Helpers
    private func getUnreadCounts() -> [String: Int] {
        guard let data = UserDefaults.standard.data(forKey: unreadCountsKey),
              let counts = try? JSONDecoder().decode([String: Int].self, from: data) else {
            return [:]
        }
        return counts
    }

    private func saveUnreadCounts(_ counts: [String: Int]) {
        if let encoded = try? JSONEncoder().encode(counts) {
            UserDefaults.standard.set(encoded, forKey: unreadCountsKey)
        }
    }

    private func updateBadge() async {
        let totalCount = getTotalUnreadCount()
        await MainActor.run {
            UNUserNotificationCenter.current().setBadgeCount(totalCount)
        }
    }
}
