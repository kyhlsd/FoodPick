//
//  TokenRepository.swift
//  Domain
//
//  Created by 김영훈 on 12/19/25.
//

import Foundation

public protocol TokenRepository: Sendable {
    func saveAccessToken(_ token: String) async throws
    func saveRefreshToken(_ token: String) async throws
    func getAccessToken() async throws -> String
    func getRefreshToken() async throws -> String
    func deleteTokens() async throws
}
