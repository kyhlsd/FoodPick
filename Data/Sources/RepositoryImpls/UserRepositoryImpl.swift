//
//  UserRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Foundation
import Domain

final class UserRepositoryImpl: UserRepository, @unchecked Sendable {
    private let networkManager: NetworkManager

    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }

    func validateEmail(_ email: String) async throws {
        try await networkManager.request(
            UserRouter.validate(email: email)
        )
    }

    func join(_ request: JoinRequest) async throws -> LoginResponse {
        let dto = JoinRequestDTO(from: request)
        guard let response = try await networkManager.request(
            UserRouter.join(dto: dto),
            responseType: LoginResponseDTO.self) else {
            throw APIError.empty
        }

        return response.toDomain
    }

    func emailLogin(email: String, password: String) async throws -> LoginResponse {
        guard let response = try await networkManager.request(
            UserRouter.emailLogin(email: email, password: password),
            responseType: LoginResponseDTO.self) else {
            throw APIError.empty
        }

        return response.toDomain
    }

    func kakaoLogin(oauthToken: String) async throws -> LoginResponse {
        guard let response = try await networkManager.request(
            UserRouter.kakaoLogin(oauthToken: oauthToken),
            responseType: LoginResponseDTO.self) else {
            throw APIError.empty
        }

        return response.toDomain
    }

    func appleLogin(idToken: String) async throws -> LoginResponse {
        guard let response = try await networkManager.request(
            UserRouter.appleLogin(idToken: idToken),
            responseType: LoginResponseDTO.self) else {
            throw APIError.empty
        }

        return response.toDomain
    }

    func logout() async throws {
        try await networkManager.request(
            UserRouter.logout
        )
    }

    func updateDeviceToken() async throws {
        try await networkManager.request(
            UserRouter.updateDeviceToken
        )
    }

    func getMyProfile() async throws -> MyProfile {
        guard let response = try await networkManager.request(
            UserRouter.getMyProfile,
            responseType: MyProfileDTO.self) else {
            throw APIError.empty
        }

        return response.toDomain
    }

    func updateMyProfile(_ request: ProfileRequest) async throws -> MyProfile {
        let dto = ProfileRequestDTO(from: request)
        guard let response = try await networkManager.request(
            UserRouter.updateMyProfile(dto: dto),
            responseType: MyProfileDTO.self) else {
            throw APIError.empty
        }

        return response.toDomain
    }

    func uploadProfileImage(_ imageData: Data, onProgress: (@Sendable (Double) -> Void)? = nil) async throws -> UploadProfileImageResponse {
        guard let response = try await networkManager.request(
            UserRouter.uploadProfileImage(image: imageData),
            responseType: UploadProfileImageResponseDTO.self,
            onProgress: onProgress
        ) else {
            throw APIError.empty
        }

        return response.toDomain
    }

    func searchUsers(nickname: String) async throws -> [Profile] {
        guard let response = try await networkManager.request(
            UserRouter.search(nickname: nickname),
            responseType: SearchUserResponseDTO.self
        ) else {
            throw APIError.empty
        }

        return response.toDomain
    }
}
