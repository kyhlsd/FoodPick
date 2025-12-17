//
//  PostByLocationRequest.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

public struct PostByLocationRequest {
    public let category: StoreCategory?
    public let longitude: Float?
    public let latitude: Float?
    public let maxDistance: Float?
    public let next: String?
    public let limit: Int?
    public let orderBy: PostOrderBy
    
    public init(category: StoreCategory?, longitude: Float?, latitude: Float?, maxDistance: Float?, next: String?, limit: Int?, orderBy: PostOrderBy) {
        self.category = category
        self.longitude = longitude
        self.latitude = latitude
        self.maxDistance = maxDistance
        self.next = next
        self.limit = limit
        self.orderBy = orderBy
    }
}
