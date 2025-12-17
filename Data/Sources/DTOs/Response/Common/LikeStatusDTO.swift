//
//  LikeStatusDTO.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Domain

struct LikeStatusDTO: ResponseDTO {
    private let likeStatus: Bool
    
    enum CodingKeys: String, CodingKey {
        case likeStatus = "like_status"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.likeStatus = try container.decode(Bool.self, forKey: .likeStatus)
    }
}

extension LikeStatusDTO {
    var toDomain: LikeStatus {
        return .init(likeStatus: likeStatus)
    }
}
