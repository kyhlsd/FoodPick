//
//  VideoResponseDTO.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Domain
import Core

struct VideoResponseDTO: ResponseDTO {
    private let id: String
    private let fileName: String
    private let title: String
    private let description: String
    private let duration: Float
    private let thumbnailURL: String
    private let availableQualities: [String]
    private let viewCount: Int
    private let likeCount: Int
    private let isLiked: Bool
    private let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case fileName = "file_name"
        case title
        case description
        case duration
        case thumbnailURL = "thumbnail_url"
        case availableQualities = "available_qualities"
        case viewCount = "view_count"
        case likeCount = "like_count"
        case isLiked = "is_liked"
        case createdAt
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.fileName = try container.decode(String.self, forKey: .fileName)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.duration = try container.decode(Float.self, forKey: .duration)
        self.thumbnailURL = try container.decode(String.self, forKey: .thumbnailURL)
        self.availableQualities = try container.decode([String].self, forKey: .availableQualities)
        self.viewCount = try container.decode(Int.self, forKey: .viewCount)
        self.likeCount = try container.decode(Int.self, forKey: .likeCount)
        self.isLiked = try container.decode(Bool.self, forKey: .isLiked)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
    }
}

extension VideoResponseDTO {
    var toDomain: VideoResponse {
        let formatter = Core.DateFormatterProvider.iso8601
        return .init(id: id,
                     fileName: fileName,
                     title: title,
                     description: description,
                     duration: duration,
                     thumbnailURL: thumbnailURL,
                     availableQualities: availableQualities,
                     viewCount: viewCount,
                     likeCount: likeCount,
                     isLiked: isLiked,
                     createdAt: formatter.date(from: createdAt) ?? Date()
        )
    }
}

struct VideoListResponseDTO: ResponseDTO {
    private let data: [VideoResponseDTO]
    private let nextCursor: String?
    
    enum CodingKeys: String, CodingKey {
        case data
        case nextCursor = "next_cursor"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.data = try container.decode([VideoResponseDTO].self, forKey: .data)
        self.nextCursor = try container.decodeIfPresent(String.self, forKey: .nextCursor)
    }
}

extension VideoListResponseDTO {
    var toDomain: VideoListResponse {
        return .init(data: data.map { $0.toDomain }, nextCursor: nextCursor)
    }
}
