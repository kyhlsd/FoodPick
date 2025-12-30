//
//  ChatRoom.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public struct ChatRoom: Sendable {
    public let roomId: String
    public let createdAt: Date
    public let updatedAt: Date
    public let participants: [Profile]
    public let lastChat: Chat?
    
    public init(roomId: String, createdAt: Date, updatedAt: Date, participants: [Profile], lastChat: Chat?) {
        self.roomId = roomId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.participants = participants
        self.lastChat = lastChat
    }
}
