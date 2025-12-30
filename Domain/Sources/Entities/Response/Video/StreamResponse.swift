//
//  StreamResponse.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

public struct StreamResponse: Sendable {
    public let videoId: String
    public let streamURL: String
    public let qualities: QualityURLResponse
    public let subtitles: [Subtitle]
    
    public init(videoId: String, streamURL: String, qualities: QualityURLResponse, subtitles: [Subtitle]) {
        self.videoId = videoId
        self.streamURL = streamURL
        self.qualities = qualities
        self.subtitles = subtitles
    }
}

public struct QualityURLResponse: Sendable {
    public let quality: String
    public let url: String
    
    public init(quality: String, url: String) {
        self.quality = quality
        self.url = url
    }
}

public struct Subtitle: Sendable {
    public let language: String
    public let name: String
    public let isDefault: Bool
    public let url: String
    
    public init(language: String, name: String, isDefault: Bool, url: String) {
        self.language = language
        self.name = name
        self.isDefault = isDefault
        self.url = url
    }
}
