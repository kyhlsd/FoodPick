//
//  UserRepository.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

import Foundation
import Core

public protocol UserRepository: Sendable {
    func checkEmailDuplication(_ email: String) async throws
    func join(_ request: JoinRequest) async throws -> LoginResponse
    func emailLogin(email: String, password: String, deviceToken: String) async throws -> LoginResponse
    func kakaoLogin(oauthToken: String, deviceToken: String) async throws -> LoginResponse
    func appleLogin(idToken: String, deviceToken: String) async throws -> LoginResponse
    func logout() async throws
    func updateDeviceToken(deviceToken: String) async throws
    func fetchMyProfile() async throws -> MyProfile
    func updateMyProfile(_ request: ProfileRequest) async throws -> MyProfile
    func uploadProfileImage(_ imageData: Data, imageType: BasicImageType, onProgress: (@Sendable (Double) -> Void)?) async throws -> ProfileImageResponse
    func searchUsers(nickname: String) async throws -> [Profile]
}
