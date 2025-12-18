//
//  UserDependency.swift
//  Presentation
//
//  Created by 김영훈 on 12/19/25.
//

import Domain
import Data
import ComposableArchitecture

extension DependencyValues {
    
    // MARK: - Repository
    var userRepository: UserRepository {
        get { self[UserRepositoryKey.self] }
        set { self[UserRepositoryKey.self] = newValue }
    }
    
    var tokenRepository: TokenRepository {
        get { self[TokenRepositoryKey.self] }
        set { self[TokenRepositoryKey.self] = newValue }
    }
    
    // MARK: - UseCases
    var checkEmailDuplication: CheckEmailDuplicationUseCase {
        get { self[CheckEmailDuplicationKey.self] }
        set { self[CheckEmailDuplicationKey.self] = newValue }
    }

    var join: JoinUseCase {
        get { self[JoinUseCaseKey.self] }
        set { self[JoinUseCaseKey.self] = newValue }
    }

    var login: LoginUseCase {
        get { self[LoginKey.self] }
        set { self[LoginKey.self] = newValue }
    }

    var logout: LogoutUseCase {
        get { self[LogoutKey.self] }
        set { self[LogoutKey.self] = newValue }
    }

    var fetchMyProfile: FetchMyProfileUseCase {
        get { self[FetchMyProfileKey.self] }
        set { self[FetchMyProfileKey.self] = newValue }
    }

    var updateMyProfile: UpdateMyProfileUseCase {
        get { self[UpdateMyProfileKey.self] }
        set { self[UpdateMyProfileKey.self] = newValue }
    }

    var uploadProfileImage: UploadProfileImageUseCase {
        get { self[UploadProfileImageKey.self] }
        set { self[UploadProfileImageKey.self] = newValue }
    }

    var searchUsers: SearchUsersUseCase {
        get { self[SearchUsersKey.self] }
        set { self[SearchUsersKey.self] = newValue }
    }

    var updateDeviceToken: UpdateDeviceTokenUseCase {
        get { self[UpdateDeviceTokenKey.self] }
        set { self[UpdateDeviceTokenKey.self] = newValue }
    }

    var getDeviceToken: GetDeviceTokenUseCase {
        get { self[GetDeviceTokenKey.self] }
        set { self[GetDeviceTokenKey.self] = newValue }
    }

    var signUpInputValidation: SignUpInputValidationUseCase {
        get { self[SignUpInputValidationKey.self] }
        set { self[SignUpInputValidationKey.self] = newValue }
    }

    var saveTokens: SaveTokensUseCase {
        get { self[SaveTokensKey.self] }
        set { self[SaveTokensKey.self] = newValue }
    }
}

// MARK: - Keys
private enum UserRepositoryKey: DependencyKey {
    static let liveValue: UserRepository = DefaultUserRepositoryImpl()
}

private enum TokenRepositoryKey: DependencyKey {
    static let liveValue: TokenRepository = DefaultTokenRepositoryImpl()
}

private enum CheckEmailDuplicationKey: DependencyKey {
    static let liveValue: CheckEmailDuplicationUseCase = {
        @Dependency(\.userRepository) var userRepository
        return CheckEmailDuplicationUseCaseImpl(userRepository: userRepository)
    }()
}

private enum JoinUseCaseKey: DependencyKey {
    static let liveValue: JoinUseCase = {
        @Dependency(\.userRepository) var userRepository
        return JoinUseCaseImpl(userRepository: userRepository)
    }()
}

private enum LoginKey: DependencyKey {
    static let liveValue: LoginUseCase = {
        @Dependency(\.userRepository) var userRepository
        return LoginUseCaseImpl(userRepository: userRepository)
    }()
}

private enum LogoutKey: DependencyKey {
    static let liveValue: LogoutUseCase = {
        @Dependency(\.userRepository) var userRepository
        return LogoutUseCaseImpl(userRepository: userRepository)
    }()
}

private enum FetchMyProfileKey: DependencyKey {
    static let liveValue: FetchMyProfileUseCase = {
        @Dependency(\.userRepository) var userRepository
        return FetchMyProfileUseCaseImpl(userRepository: userRepository)
    }()
}

private enum UpdateMyProfileKey: DependencyKey {
    static let liveValue: UpdateMyProfileUseCase = {
        @Dependency(\.userRepository) var userRepository
        return UpdateMyProfileUseCaseImpl(userRepository: userRepository)
    }()
}

private enum UploadProfileImageKey: DependencyKey {
    static let liveValue: UploadProfileImageUseCase = {
        @Dependency(\.userRepository) var userRepository
        return UploadProfileImageUseCaseImpl(userRepository: userRepository)
    }()
}

private enum SearchUsersKey: DependencyKey {
    static let liveValue: SearchUsersUseCase = {
        @Dependency(\.userRepository) var userRepository
        return SearchUsersUseCaseImpl(userRepository: userRepository)
    }()
}

private enum UpdateDeviceTokenKey: DependencyKey {
    static let liveValue: UpdateDeviceTokenUseCase = {
        @Dependency(\.userRepository) var userRepository
        return UpdateDeviceTokenUseCaseImpl(userRepository: userRepository)
    }()
}

private enum GetDeviceTokenKey: DependencyKey {
    static let liveValue: GetDeviceTokenUseCase = GetDeviceTokenUseCaseImpl()
}

private enum SignUpInputValidationKey: DependencyKey {
    static let liveValue: SignUpInputValidationUseCase = SignUpInputValidationUseCaseImpl()
}

private enum SaveTokensKey: DependencyKey {
    static let liveValue: SaveTokensUseCase = {
        @Dependency(\.tokenRepository) var tokenRepository
        return SaveTokensUseCaseImpl(tokenRepository: tokenRepository)
    }()
}
