//
//  AuthRepository.swift
//  Domain
//
//  Created by 김영훈 on 12/19/25.
//

import Foundation

public protocol AuthRepository: Sendable {
    func initializeKakaoSDK() async
    func handleKakaoOpenURL(_ url: URL) async -> Bool
    func signInWithApple() async throws -> String
    func signInWithKakao() async throws -> String
}
