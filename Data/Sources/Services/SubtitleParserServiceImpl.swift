//
//  SubtitleParserServiceImpl.swift
//  Data
//
//  Created by 김영훈 on 1/10/26.
//

import Foundation
import Domain

public final class SubtitleParserServiceImpl: SubtitleParserService {
    public init() {}

    public func parseWebVTT(_ content: String) -> [SubtitleCue] {
        var cues: [SubtitleCue] = []
        let lines = content.components(separatedBy: .newlines)

        var index = 0
        while index < lines.count {
            let line = lines[index].trimmingCharacters(in: .whitespaces)

            // 타임스탬프 라인 찾기 (00:00.000 --> 00:01.034 형식)
            if line.contains("-->") {
                let parts = line.components(separatedBy: "-->")
                guard parts.count == 2 else {
                    index += 1
                    continue
                }

                let startTime = parseTime(parts[0].trimmingCharacters(in: .whitespaces))
                let endTime = parseTime(parts[1].trimmingCharacters(in: .whitespaces))

                // 다음 라인부터 자막 텍스트 수집
                index += 1
                var text = ""
                while index < lines.count {
                    let textLine = lines[index].trimmingCharacters(in: .whitespaces)
                    if textLine.isEmpty {
                        break
                    }
                    if !text.isEmpty {
                        text += " "
                    }
                    text += textLine
                    index += 1
                }

                cues.append(SubtitleCue(start: startTime, end: endTime, text: text))
            }

            index += 1
        }

        return cues
    }

    private func parseTime(_ timeString: String) -> TimeInterval {
        // 00:00.000 또는 00:00:00.000 형식 파싱
        let components = timeString.components(separatedBy: ":")
        var hours: Double = 0
        var minutes: Double = 0
        var seconds: Double = 0

        if components.count == 3 {
            hours = Double(components[0]) ?? 0
            minutes = Double(components[1]) ?? 0
            seconds = Double(components[2]) ?? 0
        } else if components.count == 2 {
            minutes = Double(components[0]) ?? 0
            seconds = Double(components[1]) ?? 0
        }

        return hours * 3600 + minutes * 60 + seconds
    }
}
