//
//  ChatRoomDTO.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Domain
import Core

struct ChatRoomDTO: ResponseDTO {
    private let roomId: String
    private let createdAt: String
    private let updatedAt: String
    private let participants: [ProfileDTO]
    private let lastChat: ChatDTO?
    
    enum CodingKeys: String, CodingKey {
        case roomId = "room_id"
        case createdAt
        case updatedAt
        case participants
        case lastChat
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.roomId = try container.decode(String.self, forKey: .roomId)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.updatedAt = try container.decode(String.self, forKey: .updatedAt)
        self.participants = try container.decode([ProfileDTO].self, forKey: .participants)
        self.lastChat = try container.decodeIfPresent(ChatDTO.self, forKey: .lastChat)
    }
}

extension ChatRoomDTO {
    var toDomain: ChatRoom {
        let formatter = Core.DateFormatterProvider.iso8601
        return .init(roomId: roomId,
                     createdAt: formatter.date(from: createdAt) ?? Date(),
                     updatedAt: formatter.date(from: updatedAt) ?? Date(),
                     participants: participants.map { $0.toDomain },
                     lastChat: lastChat?.toDomain
        )
    }
}
