//
//  UploadFilesUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Core

public protocol UploadFilesUseCase: Sendable {
    func execute(datas: [(Data, MediaType)], onProgress: (@Sendable (Double) -> Void)?) async throws -> [String]
}

public final class UploadFilesUseCaseImpl: UploadFilesUseCase, @unchecked Sendable {
    private let postRepository: PostRepository

    public init(postRepository: PostRepository) {
        self.postRepository = postRepository
    }

    public func execute(datas: [(Data, MediaType)], onProgress: (@Sendable (Double) -> Void)?) async throws -> [String] {
        return try await postRepository.uploadFiles(datas: datas, onProgress: onProgress)
    }
}
