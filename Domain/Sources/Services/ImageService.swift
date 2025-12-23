//
//  ImageService.swift
//  Domain
//
//  Created by 김영훈 on 12/23/25.
//

import Foundation

public protocol ImageService: Sendable {
    func makeAuthenticatedRequest(for imagePath: String) async throws -> URLRequest
}
