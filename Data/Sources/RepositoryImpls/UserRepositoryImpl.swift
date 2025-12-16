//
//  UserRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Foundation
import Domain

public final class UserRepositoryImpl: UserRepository, @unchecked Sendable {
    private let networkManager = NetworkManager.shared

    public init() {}

    public func validateEmail(_ email: String) async throws {
        try await networkManager.request(
            UserRouter.validate(email: email)
        )
    }

    public func join(_ request: JoinRequest) async throws -> LoginResponse {
        let dto = JoinRequestDTO(from: request)
        guard let response = try await networkManager.request(
            UserRouter.join(dto: dto),
            responseType: LoginResponseDTO.self) else {
            throw APIError.empty
        }

        return response.toDomain
    }

    public func emailLogin(email: String, password: String) async throws -> LoginResponse {
        guard let response = try await networkManager.request(
            UserRouter.emailLogin(email: email, password: password),
            responseType: LoginResponseDTO.self) else {
            throw APIError.empty
        }

        return response.toDomain
    }

    public func kakaoLogin(oauthToken: String) async throws -> LoginResponse {
        guard let response = try await networkManager.request(
            UserRouter.kakaoLogin(oauthToken: oauthToken),
            responseType: LoginResponseDTO.self) else {
            throw APIError.empty
        }

        return response.toDomain
    }

    public func appleLogin(idToken: String) async throws -> LoginResponse {
        guard let response = try await networkManager.request(
            UserRouter.appleLogin(idToken: idToken),
            responseType: LoginResponseDTO.self) else {
            throw APIError.empty
        }

        return response.toDomain
    }

    public func logout() async throws {
        try await networkManager.request(
            UserRouter.logout
        )
    }

    public func updateDeviceToken() async throws {
        try await networkManager.request(
            UserRouter.deviceToken
        )
    }

    public func getMyProfile() async throws -> MyProfile {
        guard let response = try await networkManager.request(
            UserRouter.myProfile(),
            responseType: MyProfileDTO.self) else {
            throw APIError.empty
        }

        return response.toDomain
    }

    public func updateMyProfile(_ request: ProfileRequest) async throws -> MyProfile {
        let dto = ProfileRequestDTO(from: request)
        guard let response = try await networkManager.request(
            UserRouter.myProfile(dto: dto),
            responseType: MyProfileDTO.self) else {
            throw APIError.empty
        }

        return response.toDomain
    }

    public func uploadProfileImage(_ imageData: Data, onProgress: (@Sendable (Double) -> Void)? = nil) async throws -> UploadProfileImageResponse {
        guard let response = try await networkManager.request(
            UserRouter.profileImage(image: imageData),
            responseType: UploadProfileImageResponseDTO.self,
            onProgress: onProgress
        ) else {
            throw APIError.empty
        }

        return response.toDomain
    }

    public func searchUsers(nickname: String) async throws -> [Profile] {
        guard let response = try await networkManager.request(
            UserRouter.search(nickname: nickname),
            responseType: SearchUserResponseDTO.self
        ) else {
            throw APIError.empty
        }

        return response.toDomain
    }
}
