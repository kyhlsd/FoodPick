//
//  FetchSubtitleUseCaseDependency.swift
//  Presentation
//
//  Created by 김영훈 on 1/10/26.
//

import Domain
import Data
import ComposableArchitecture

extension DependencyValues {
    var fetchSubtitle: FetchSubtitleUseCase {
        get { self[FetchSubtitleUseCaseKey.self] }
        set { self[FetchSubtitleUseCaseKey.self] = newValue }
    }
}

private enum FetchSubtitleUseCaseKey: DependencyKey {
    static let liveValue: FetchSubtitleUseCase = FetchSubtitleUseCaseImpl(
        videoRepository: DefaultVideoRepositoryImpl(),
        subtitleParser: SubtitleParserServiceImpl()
    )
}
