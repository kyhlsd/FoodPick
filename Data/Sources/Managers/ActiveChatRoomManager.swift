//
//  ActiveChatRoomManager.swift
//  Data
//
//  Created by Claude on 1/9/26.
//

import Foundation

public actor ActiveChatRoomManager {
    public static let shared = ActiveChatRoomManager()

    private var activeChatRoomId: String?

    private init() {}

    public func setActiveChatRoom(_ roomId: String?) {
        activeChatRoomId = roomId
    }

    public func getActiveChatRoom() -> String? {
        return activeChatRoomId
    }
}
