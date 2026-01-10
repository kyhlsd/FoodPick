//
//  FetchSubtitleUseCase.swift
//  Domain
//
//  Created by 김영훈 on 1/10/26.
//

import Foundation

public protocol FetchSubtitleUseCase: Sendable {
    func execute(subtitle: Subtitle) async throws -> [SubtitleCue]
}

public final class FetchSubtitleUseCaseImpl: FetchSubtitleUseCase, @unchecked Sendable {
    private let videoRepository: VideoRepository
    private let subtitleParser: SubtitleParserService

    public init(videoRepository: VideoRepository, subtitleParser: SubtitleParserService) {
        self.videoRepository = videoRepository
        self.subtitleParser = subtitleParser
    }

    public func execute(subtitle: Subtitle) async throws -> [SubtitleCue] {
        let subtitleContent = try await videoRepository.fetchSubtitle(path: subtitle.url)
        return subtitleParser.parseWebVTT(subtitleContent)
    }
}
