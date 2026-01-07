//
//  MultipleAuthenticatedMedia.swift
//  Presentation
//
//  Created by 김영훈 on 1/8/26.
//

import SwiftUI

struct MultipleAuthenticatedMedia: View {
    let files: [String]
    
    var body: some View {
        switch files.count {
        case 0:
            EmptyView()
        case 1:
            SingleGrid(file: files.first)
        case 3:
            ThreeMediaGrid(files: files)
        case 5:
            FiveMediaGrid(files: files)
        default:
            MultipleGrid(files: files)
        }
    }
}

private struct SingleGrid: View {
    let file: String?
    
    var body: some View {
        AuthenticatedMedia(mediaPath: file, showsPlaybackControls: false)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .aspectRatio(3 / 2, contentMode: .fit)
    }
}

private struct MultipleGrid: View {
    let files: [String]
    
    private var columns: [GridItem] {
        let count = (files.count == 2 || files.count == 4) ? 2 : 3
        return Array(repeating: GridItem(.flexible(), spacing: AppPadding.tiny.value), count: count)
    }
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: AppPadding.tiny.value) {
            ForEach(0..<min(files.count, 6), id: \.self) { index in
                AuthenticatedMedia(mediaPath: files[index], showsPlaybackControls: false)
                    .aspectRatio(1, contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ThreeMediaGrid: View {
    let files: [String]
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            // 왼쪽 큰 정사각형 (2/3 너비)
            let largeSize = (width - AppPadding.tiny.value) * 2 / 3
            // 오른쪽 작은 정사각형 (1/3 너비)
            let smallSize = (largeSize - AppPadding.tiny.value) / 2
            
            HStack(spacing: AppPadding.tiny.value) {
                AuthenticatedMedia(
                    mediaPath: !files.isEmpty ? files[0] : nil,
                    showsPlaybackControls: true
                )
                .frame(width: largeSize, height: largeSize)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(spacing: AppPadding.tiny.value) {
                    AuthenticatedMedia(
                        mediaPath: files.count > 1 ? files[1] : nil,
                        showsPlaybackControls: false
                    )
                    .frame(width: smallSize, height: smallSize)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                    AuthenticatedMedia(
                        mediaPath: files.count > 2 ? files[2] : nil,
                        showsPlaybackControls: false
                    )
                    .frame(width: smallSize, height: smallSize)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .aspectRatio(3 / 2, contentMode: .fit)
    }
}

private struct FiveMediaGrid: View {
    let files: [String]
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let spacing = AppPadding.tiny.value
            
            let twoItemSize = (width - spacing) / 2
            let threeItemSize = (width - (spacing * 2)) / 3
            
            VStack(spacing: spacing) {
                // 상단 2개
                HStack(spacing: spacing) {
                    ForEach(0..<2) { index in
                        AuthenticatedMedia(mediaPath: files[index], showsPlaybackControls: false)
                            .frame(width: twoItemSize, height: twoItemSize)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                
                // 하단 3개
                HStack(spacing: spacing) {
                    ForEach(2..<5) { index in
                        AuthenticatedMedia(mediaPath: files[index], showsPlaybackControls: false)
                            .frame(width: threeItemSize, height: threeItemSize)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            MultipleAuthenticatedMedia(files: .init(repeating: "", count: 1))
            
            MultipleAuthenticatedMedia(files: .init(repeating: "", count: 2))
            
            MultipleAuthenticatedMedia(files: .init(repeating: "", count: 3))
            
            MultipleAuthenticatedMedia(files: .init(repeating: "", count: 4))
            
            MultipleAuthenticatedMedia(files: .init(repeating: "", count: 5))
        }
    }
}
