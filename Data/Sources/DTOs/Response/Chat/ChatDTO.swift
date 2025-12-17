//
//  ChatDTO.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Domain
import Core

struct ChatDTO: ResponseDTO {
    private let chatId: String
    private let roomId: String
    private let content: String
    private let createdAt: String
    private let updatedAt: String
    private let sender: ProfileDTO
    private let files: [String]?
    
    enum CodingKeys: String, CodingKey {
        case chatId = "chat_id"
        case roomId = "room_id"
        case content
        case createdAt
        case updatedAt
        case sender
        case files
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.chatId = try container.decode(String.self, forKey: .chatId)
        self.roomId = try container.decode(String.self, forKey: .roomId)
        self.content = try container.decode(String.self, forKey: .content)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.updatedAt = try container.decode(String.self, forKey: .updatedAt)
        self.sender = try container.decode(ProfileDTO.self, forKey: .sender)
        self.files = try container.decodeIfPresent([String].self, forKey: .files)
    }
}

extension ChatDTO {
    var toDomain: Chat {
        let formatter = Core.DateFormatterProvider.iso8601
        return .init(chatId: chatId,
                     roomId: roomId,
                     content: content,
                     createdAt: formatter.date(from: createdAt) ?? Date(),
                     updatedAt: formatter.date(from: updatedAt) ?? Date(),
                     sender: sender.toDomain,
                     files: files
        )
    }
}
