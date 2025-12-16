//
//  ListWithCursorDTO.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Domain

struct ListWithCursorDTO<T: ResponseDTO>: ResponseDTO {
    private let data: [T]
    private let nextCursor: String
    
    enum CodingKeys: String, CodingKey {
        case data
        case nextCursor = "next_cursor"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.data = try container.decode([T].self, forKey: .data)
        self.nextCursor = try container.decode(String.self, forKey: .nextCursor)
    }
}

extension ListWithCursorDTO {
    var toDomain: ListWithCursor<T.Entity> {
        return .init(data: data.map { $0.toDomain }, nextCursor: nextCursor)
    }
}
