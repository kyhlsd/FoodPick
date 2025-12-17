//
//  VideoPageRequest.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

public struct VideoPageRequest {
    public let next: String?
    public let limit: Int?
    
    public init(next: String?, limit: Int?) {
        self.next = next
        self.limit = limit
    }
}
