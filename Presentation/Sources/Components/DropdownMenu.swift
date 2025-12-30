//
//  DropdownMenu.swift
//  Presentation
//
//  Created by 김영훈 on 12/25/25.
//

import SwiftUI

struct DropdownMenu<T: Hashable>: View {
    let options: [T]
    let selectedOption: T
    let isOpen: Bool
    let optionLabel: (T) -> String
    let onToggle: () -> Void
    let onSelect: (T) -> Void
    let label: (T) -> AnyView

    var body: some View {
        Button {
            onToggle()
        } label: {
            label(selectedOption)
        }
        .overlay(alignment: .topTrailing) {
            if isOpen {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(options, id: \.self) { option in
                        Button {
                            onSelect(option)
                        } label: {
                            HStack(spacing: AppPadding.small.value) {
                                if selectedOption == option {
                                    AppIcon.check
                                        .resizable()
                                        .frame(width: 12, height: 12)
                                        .foregroundStyle(.custom(.brand(.blackSprout)))
                                } else {
                                    Color.clear
                                        .frame(width: 12, height: 12)
                                }

                                Text(optionLabel(option))
                                    .font(.pretendard(size: .caption1, weight: .semiBold))
                                    .foregroundStyle(selectedOption == option
                                        ? .custom(.brand(.blackSprout))
                                        : .custom(.gray(.gray60))
                                    )
                            }
                            .padding(.horizontal, AppPadding.medium.value)
                            .padding(.vertical, AppPadding.small.value)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        if option != options.last {
                            MyDivider()
                        }
                    }
                }
                .background(.custom(.gray(.gray0)))
                .cornerRadius(8)
                .shadow(color: .custom(.gray(.gray60)).opacity(0.16), radius: 8, x: 0, y: 2)
                .fixedSize(horizontal: true, vertical: false)
                .offset(y: 30)
            }
        }
        .zIndex(isOpen ? 1000 : 0)
    }
}

// MARK: - Convenience Initializer for RawRepresentable
extension DropdownMenu where T: RawRepresentable, T.RawValue == String {
    init(
        options: [T],
        selectedOption: T,
        isOpen: Bool,
        onToggle: @escaping () -> Void,
        onSelect: @escaping (T) -> Void,
        @ViewBuilder label: @escaping (T) -> some View
    ) {
        self.options = options
        self.selectedOption = selectedOption
        self.isOpen = isOpen
        self.optionLabel = { $0.rawValue }
        self.onToggle = onToggle
        self.onSelect = onSelect
        self.label = { option in AnyView(label(option)) }
    }
}

// MARK: - View Extension for Dropdown
extension View {
    func dropdownHost(isOpen: Bool, onDismiss: @escaping () -> Void) -> some View {
        self
            .zIndex(isOpen ? 1000 : 0)
            .background(
                Group {
                    if isOpen {
                        Color.clear
                            .ignoresSafeArea()
                            .contentShape(Rectangle())
                            .onTapGesture {
                                onDismiss()
                            }
                    }
                }
            )
    }

    func dropdownBackdrop(isOpen: Bool, onDismiss: @escaping () -> Void) -> some View {
        self
            .overlay(
                Group {
                    if isOpen {
                        Color.clear
                            .ignoresSafeArea()
                            .contentShape(Rectangle())
                            .onTapGesture {
                                onDismiss()
                            }
                    }
                }
            )
    }
}
