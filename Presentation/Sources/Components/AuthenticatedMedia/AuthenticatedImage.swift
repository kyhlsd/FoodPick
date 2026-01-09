//
//  AuthenticatedImage.swift
//  Presentation
//
//  Created by 김영훈 on 12/23/25.
//

import SwiftUI
import Domain
import Data
import ComposableArchitecture
import Kingfisher

struct AuthenticatedImage: View {
    private let imagePath: String?
    private let placeholder: AnyView?

    @State private var modifier: AnyModifier?
    @State private var loadingFailed: Bool = false
    @State private var imageURL: URL?
    @Dependency(\.fileService) var fileService

    init(
        imagePath: String?,
        @ViewBuilder placeholder: () -> some View = { ProgressView() }
    ) {
        self.imagePath = imagePath
        self.placeholder = AnyView(placeholder())
    }

    var body: some View {
        GeometryReader { geometry in
            let isSmall = min(geometry.size.width, geometry.size.height) < 120

            Group {
                if imagePath == nil {
                    if isSmall {
                        AppIcon.photo
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(.custom(.gray(.gray45)))
                            .padding(AppPadding.medium.value)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.custom(.gray(.gray30)))
                    } else {
                        VStack(spacing: AppPadding.small.value) {
                            AppIcon.photo
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundStyle(.custom(.gray(.gray45)))
                            Text("이미지가 없습니다")
                                .font(.pretendard(size: .body3, weight: .medium))
                                .foregroundStyle(.custom(.gray(.gray45)))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.custom(.gray(.gray30)))
                    }
                } else if loadingFailed {
                    if isSmall {
                        AppIcon.exclamationMark
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(.custom(.gray(.gray45)))
                            .padding(AppPadding.medium.value)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.custom(.gray(.gray30)))
                    } else {
                        VStack(spacing: AppPadding.small.value) {
                            AppIcon.exclamationMark
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundStyle(.custom(.gray(.gray45)))
                            Text("이미지 로딩 실패")
                                .font(.pretendard(size: .body3, weight: .medium))
                                .foregroundStyle(.custom(.gray(.gray45)))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.custom(.gray(.gray30)))
                    }
                } else if let imageURL, let modifier {
                    KFImage(imageURL)
                        .requestModifier(modifier)
                        .setProcessor(DownsamplingImageProcessor(size: geometry.size))
                        .placeholder { placeholder }
                        .cacheOriginalImage(false)
                        .diskCacheExpiration(.days(7))
                        .onFailure { _ in
                            loadingFailed = true
                        }
                        .resizable()
                } else {
                    placeholder
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .task {
            if let imagePath {
                do {
                    let request = try await fileService.makeAuthenticatedRequest(for: imagePath)
                    if let url = request.url {
                        imageURL = url
                        modifier = AnyModifier { _ in request }
                    }
                } catch {
                    loadingFailed = true
                }
            }
        }
    }
}
