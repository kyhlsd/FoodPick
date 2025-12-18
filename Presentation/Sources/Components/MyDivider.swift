//
//  MyDivider.swift
//  Presentation
//
//  Created by 김영훈 on 12/18/25.
//

import SwiftUI

struct MyDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.custom(.gray(.gray30)))
            .frame(height: 1)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    MyDivider()
}
