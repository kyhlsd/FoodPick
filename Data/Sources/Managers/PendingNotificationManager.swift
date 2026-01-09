//
//  PendingNotificationManager.swift
//  Data
//
//  Created by Claude on 1/10/26.
//

import Foundation

public actor PendingNotificationManager {
    public static let shared = PendingNotificationManager()

    private var pendingChatNotification: (roomId: String, date: Date)?

    private init() {}

    public func setPendingChatNotification(roomId: String, date: Date) {
        pendingChatNotification = (roomId, date)
    }

    public func consumePendingChatNotification() -> (roomId: String, date: Date)? {
        let notification = pendingChatNotification
        pendingChatNotification = nil
        return notification
    }
}
