//
//  BannerListView.swift
//  Presentation
//
//  Created by 김영훈 on 12/23/25.
//

import SwiftUI
import ComposableArchitecture
import Domain

struct BannerListView: View {
//    let banners: [BannerItem]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
//                ForEach(banners) { banner in
//                    BannerItemView(imageURL: banner.imageURL)
//                }
            }
            .padding(.horizontal)
        }
    }
}

private struct BannerItemView: View {
    let imagePath: String?

    var body: some View {
        AuthenticatedImage(imagePath: imagePath)
            .frame(width: 300, height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Preview Data
private struct BannerItem: Identifiable {
    let id: String
    let imagePath: String?
}
