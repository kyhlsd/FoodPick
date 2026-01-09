//
//  ActiveChatRoomManager.swift
//  Data
//
//  Created by Claude on 1/9/26.
//

import Foundation

/// 현재 활성화된 채팅방 ID를 추적하는 매니저
public actor ActiveChatRoomManager {
    public static let shared = ActiveChatRoomManager()

    private var activeChatRoomId: String?

    private init() {}

    /// 활성화된 채팅방 ID 설정
    public func setActiveChatRoom(_ roomId: String?) {
        activeChatRoomId = roomId
    }

    /// 현재 활성화된 채팅방 ID 가져오기
    public func getActiveChatRoom() -> String? {
        return activeChatRoomId
    }
}
