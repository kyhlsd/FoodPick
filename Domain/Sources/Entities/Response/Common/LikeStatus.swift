//
//  LikeStatus.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public struct LikeStatus: Sendable {
    public let likeStatus: Bool
    
    public init(likeStatus: Bool) {
        self.likeStatus = likeStatus
    }
}
