//
//  SubtitleParserDependency.swift
//  Presentation
//
//  Created by 김영훈 on 1/10/26.
//

import Domain
import Data
import ComposableArchitecture

extension DependencyValues {
    var subtitleParser: SubtitleParserService {
        get { self[SubtitleParserKey.self] }
        set { self[SubtitleParserKey.self] = newValue }
    }
}

private enum SubtitleParserKey: DependencyKey {
    static let liveValue: SubtitleParserService = SubtitleParserServiceImpl()
}
