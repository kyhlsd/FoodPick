//
//  AppPadding.swift
//  Presentation
//
//  Created by 김영훈 on 12/12/25.
//

import SwiftUI

enum AppPadding {
    case tiny
    case small
    case medium
    case large
    case xLarge
    
    var value: CGFloat {
        switch self {
        case .tiny: return 4
        case .small: return 8
        case .medium: return 12
        case .large: return 16
        case .xLarge: return 20
        }
    }
}

extension View {
    func padding(_ edges: Edge.Set = .all, _ size: AppPadding) -> some View {
        return self.padding(edges, size.value)
    }
}
