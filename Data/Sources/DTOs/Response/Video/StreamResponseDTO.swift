//
//  StreamResponseDTO.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Domain

struct StreamResponseDTO: ResponseDTO {
    private let videoId: String
    private let streamURL: String
    private let qualities: [QualityURLResponseDTO]
    private let subtitles: [SubtitleDTO]

    enum CodingKeys: String, CodingKey {
        case videoId = "video_id"
        case streamURL = "stream_url"
        case qualities
        case subtitles
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.videoId = try container.decode(String.self, forKey: .videoId)
        self.streamURL = try container.decode(String.self, forKey: .streamURL)
        self.qualities = try container.decode([QualityURLResponseDTO].self, forKey: .qualities)
        self.subtitles = try container.decode([SubtitleDTO].self, forKey: .subtitles)
    }
}

extension StreamResponseDTO {
    var toDomain: StreamResponse {
        return .init(videoId: videoId,
                     streamURL: streamURL,
                     qualities: qualities.map { $0.toDomain },
                     subtitles: subtitles.map { $0.toDomain }
        )
    }
}

struct QualityURLResponseDTO: ResponseDTO {
    private let quality: String
    private let url: String
}

extension QualityURLResponseDTO {
    var toDomain: QualityURLResponse {
        return .init(quality: quality, url: url)
    }
}

struct SubtitleDTO: ResponseDTO {
    private let language: String
    private let name: String
    private let isDefault: Bool
    private let url: String
    
    enum CodingKeys: String, CodingKey {
        case language
        case name
        case isDefault = "is_default"
        case url
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.language = try container.decode(String.self, forKey: .language)
        self.name = try container.decode(String.self, forKey: .name)
        self.isDefault = try container.decode(Bool.self, forKey: .isDefault)
        self.url = try container.decode(String.self, forKey: .url)
    }
}

extension SubtitleDTO {
    var toDomain: Subtitle {
        return .init(language: language, name: name, isDefault: isDefault, url: url)
    }
}
