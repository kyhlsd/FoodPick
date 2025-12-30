//
//  ResponseListWithCursor.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public struct ResponseListWithCursor<T: Sendable>: Sendable {
    public let data: [T]
    public let nextCursor: String
    
    public init(data: [T], nextCursor: String) {
        self.data = data
        self.nextCursor = nextCursor
    }
}
