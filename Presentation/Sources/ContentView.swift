import SwiftUI
import Data
import Domain

public struct ContentView: View {
    let repository: UserRepository
    let getMyProfileUseCase: GetMyProfileUseCase
    let joinUseCase: JoinUseCase
    let loginUseCase: LoginUseCase
    let logoutUseCase: LogoutUseCase
    let searchUsersUseCase: SearchUsersUseCase
    let updateMyProfileUseCase: UpdateMyProfileUseCase
    let uploadProfileImageUseCase: UploadProfileImageUseCase
    let validateEmailUseCase: ValidateEmailUseCase
    
    public init() {
        let repository = UserRepositoryImpl()
        self.repository = repository
        self.getMyProfileUseCase = DefaultGetMyProfileUseCase(userRepository: repository)
        self.joinUseCase = DefaultJoinUseCase(userRepository: repository)
        self.loginUseCase = DefaultLoginUseCase(userRepository: repository)
        self.logoutUseCase = DefaultLogoutUseCase(userRepository: repository)
        self.searchUsersUseCase = DefaultSearchUsersUseCase(userRepository: repository)
        self.updateMyProfileUseCase = DefaultUpdateMyProfileUseCase(userRepository: repository)
        self.uploadProfileImageUseCase = DefaultUploadProfileImageUseCase(userRepository: repository)
        self.validateEmailUseCase = DefaultValidateEmailUseCase(userRepository: repository)
    }
    
    public var body: some View {
        VStack {
            Text("글씨 테스트")
                .font(.custom(.jalnan(.title1)))
                .padding(.vertical, .xLarge)
            
            Button {
                Task {
                    do {
                        let response = try await getMyProfileUseCase.execute()
                        print(response)
                    } catch {
                        print("error: \(error.localizedDescription)")
                    }
                }
            } label: {
                AppIcon.communityEmpty
                    .foregroundStyle(.custom(.brand(.blackSprout)))
            }
        }
    }
}

#Preview {
    ContentView()
}
