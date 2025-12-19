//
//  GetDeviceTokenUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/19/25.
//

import Foundation

public protocol GetDeviceTokenUseCase: Sendable {
    func execute() async throws -> String
}

public final class GetDeviceTokenUseCaseImpl: GetDeviceTokenUseCase {
    private let deviceTokenRepository: DeviceTokenRepository

    public init(deviceTokenRepository: DeviceTokenRepository) {
        self.deviceTokenRepository = deviceTokenRepository
    }

    public func execute() async throws -> String {
        return try await deviceTokenRepository.getDeviceToken()
    }
}
