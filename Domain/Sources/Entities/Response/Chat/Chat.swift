//
//  Chat.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public struct Chat {
    public let chatId: String
    public let roomId: String
    public let content: String
    public let createdAt: Date
    public let updatedAt: Date
    public let sender: Profile
    public let files: [String]?
    
    public init(chatId: String, roomId: String, content: String, createdAt: Date, updatedAt: Date, sender: Profile, files: [String]?) {
        self.chatId = chatId
        self.roomId = roomId
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.sender = sender
        self.files = files
    }
}
