//
//  AppleSignInUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/19/25.
//

import Foundation

public protocol AppleSignInUseCase: Sendable {
    func execute() async throws -> String
}

public final class AppleSignInUseCaseImpl: AppleSignInUseCase {
    private let appleSignInProvider: AppleSignInProvider

    public init(appleSignInProvider: AppleSignInProvider) {
        self.appleSignInProvider = appleSignInProvider
    }

    public func execute() async throws -> String {
        return try await appleSignInProvider.signIn()
    }
}
