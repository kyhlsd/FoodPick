//
//  AppleSignInProvider.swift
//  Domain
//
//  Created by 김영훈 on 12/19/25.
//

import Foundation

public protocol AppleSignInProvider: Sendable {
    func signIn() async throws -> String
}
