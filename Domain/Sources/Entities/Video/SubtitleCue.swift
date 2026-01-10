//
//  SubtitleCue.swift
//  Domain
//
//  Created by 김영훈 on 1/10/26.
//

import Foundation

public struct SubtitleCue: Sendable {
    public let start: TimeInterval
    public let end: TimeInterval
    public let text: String

    public init(start: TimeInterval, end: TimeInterval, text: String) {
        self.start = start
        self.end = end
        self.text = text
    }
}
