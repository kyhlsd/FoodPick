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
    private let deviceTokenProvider: DeviceTokenProvider

    public init(deviceTokenProvider: DeviceTokenProvider) {
        self.deviceTokenProvider = deviceTokenProvider
    }

    public func execute() async throws -> String {
        return try await deviceTokenProvider.getDeviceToken()
    }
}
