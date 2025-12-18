//
//  HideKeyboardModifier.swift
//  Presentation
//
//  Created by 김영훈 on 12/18/25.
//

import SwiftUI

struct HideKeyboardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil,
                    from: nil,
                    for: nil
                )
            }
    }
}

extension View {
    func hideKeyboardOnTap() -> some View {
        modifier(HideKeyboardModifier())
    }
}
