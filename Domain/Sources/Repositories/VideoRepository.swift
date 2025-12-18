//
//  VideoRepository.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public protocol VideoRepository: Sendable {
    func fetchVideoList(request: VideoPageRequest) async throws -> VideoListResponse
    func fetchVideoStream(id: String) async throws -> StreamResponse
    func likeVideo(id: String, like: Bool) async throws -> LikeStatus
}
