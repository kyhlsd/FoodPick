//
//  AuthenticatedMedia.swift
//  Presentation
//
//  Created by 김영훈 on 1/7/26.
//

import SwiftUI
import Core

struct AuthenticatedMedia: View {
    private let mediaPath: String?
    private let showsPlaybackControls: Bool

    init(
        mediaPath: String?,
        showsPlaybackControls: Bool = true
    ) {
        self.mediaPath = mediaPath
        self.showsPlaybackControls = showsPlaybackControls
    }

    var body: some View {
        Group {
            if let mediaPath {
                let mediaType = MediaType.from(path: mediaPath)

                if mediaType?.isImage == true {
                    AuthenticatedImage(imagePath: mediaPath)
                } else if mediaType?.isVideo == true {
                    AuthenticatedVideo(
                        videoPath: mediaPath,
                        showsPlaybackControls: showsPlaybackControls
                    )
                } else {
                    // 알 수 없는 타입
                    unknownMediaPlaceholder
                }
            } else {
                // Path가 nil인 경우
                emptyPlaceholder
            }
        }
    }

    // MARK: - Placeholder Views

    private var emptyPlaceholder: some View {
        VStack(spacing: AppPadding.small.value) {
            AppIcon.photo
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundStyle(.custom(.gray(.gray45)))
            Text("미디어가 없습니다")
                .font(.pretendard(size: .body3, weight: .medium))
                .foregroundStyle(.custom(.gray(.gray45)))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.custom(.gray(.gray30)))
    }

    private var unknownMediaPlaceholder: some View {
        VStack(spacing: AppPadding.small.value) {
            AppIcon.exclamationMark
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundStyle(.custom(.gray(.gray45)))
            Text("지원하지 않는 형식입니다")
                .font(.pretendard(size: .body3, weight: .medium))
                .foregroundStyle(.custom(.gray(.gray45)))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.custom(.gray(.gray30)))
    }
}
