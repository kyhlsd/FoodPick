//
//  MyDivider.swift
//  Presentation
//
//  Created by 김영훈 on 12/18/25.
//

import SwiftUI

struct MyDivider: View {
    let color: Color
    
    init(color: Color = .custom(.gray(.gray30))) {
        self.color = color
    }
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: 1)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    MyDivider()
}
