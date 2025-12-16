//
//  UserRepository.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

import Foundation

public protocol UserRepository {
    func validateEmail(_ email: String) async throws
    func join(_ request: JoinRequest) async throws -> LoginResponse
    func emailLogin(email: String, password: String) async throws -> LoginResponse
    func kakaoLogin(oauthToken: String) async throws -> LoginResponse
    func appleLogin(idToken: String) async throws -> LoginResponse
    func logout() async throws
    func updateDeviceToken() async throws
    func getMyProfile() async throws -> MyProfile
    func updateMyProfile(_ request: ProfileRequest) async throws -> MyProfile
    func uploadProfileImage(_ imageData: Data, onProgress: (@Sendable (Double) -> Void)?) async throws -> UploadProfileImageResponse
    func searchUsers(nickname: String) async throws -> [Profile]
}
