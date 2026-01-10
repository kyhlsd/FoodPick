//
//  SubtitleParserService.swift
//  Domain
//
//  Created by 김영훈 on 1/10/26.
//

import Foundation

public protocol SubtitleParserService: Sendable {
    func parseWebVTT(_ content: String) -> [SubtitleCue]
}
