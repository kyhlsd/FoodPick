//
//  SearchedRestaurantView.swift
//  Presentation
//
//  Created by 김영훈 on 12/25/25.
//

import SwiftUI
import Domain

struct SearchedRestaurantView: View {
    let searchWord: String
    let restaurants: [Restaurant]
    let isLoading: Bool
    let isPicchelinFilterEnabled: Bool
    let isMyPickFilterEnabled: Bool
    let onPicchelinFilterToggle: () -> Void
    let onMyPickFilterToggle: () -> Void
    let onLikeToggle: (String, Bool) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppPadding.medium.value) {
            Text(searchWord)
                .font(.pretendard(size: .body2, weight: .bold))
                .foregroundStyle(.custom(.gray(.gray90)))
        }
    }
}
