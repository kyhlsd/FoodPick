//
//  BasicRequest.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public struct BasicRequest {
    public let category: RestaurantCategory?
    public let next: String?
    public let limit: Int?
    
    public init(category: RestaurantCategory?, next: String?, limit: Int?) {
        self.category = category
        self.next = next
        self.limit = limit
    }
}
