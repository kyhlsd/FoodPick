//
//  FileServiceDependency.swift
//  Presentation
//
//  Created by 김영훈 on 12/23/25.
//

import Domain
import Data
import ComposableArchitecture

extension DependencyValues {
    // MARK: - File Service
    var fileService: FileService {
        get { self[FileServiceKey.self] }
        set { self[FileServiceKey.self] = newValue }
    }
}

// MARK: - Keys
private enum FileServiceKey: DependencyKey {
    static let liveValue: FileService = {
        @Dependency(\.tokenRepository) var tokenRepository
        return FileServiceImpl(tokenRepository: tokenRepository)
    }()
}
