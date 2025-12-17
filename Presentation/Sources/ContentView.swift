import SwiftUI
import Data
import Domain
import Core

public struct ContentView: View {
    let repository: ChatRepository
    let fetchChatListUseCase: FetchChatListUseCase
    let fetchChatRoomUseCase: FetchChatRoomUseCase
    let fetchChatRoomListUseCase: FetchChatRoomListUseCase
    let sendMessageUseCase: SendMessageUseCase
    let uploadChatFilesUseCase: UploadChatFilesUseCase

    public init() {
        self.repository = DefaultChatRepositoryImpl()
        self.fetchChatListUseCase = FetchChatListUseCaseImpl(chatRepository: repository)
        self.fetchChatRoomUseCase = FetchChatRoomUseCaseImpl(chatRepository: repository)
        self.fetchChatRoomListUseCase = FetchChatRoomListUseCaseImpl(chatRepository: repository)
        self.sendMessageUseCase = SendMessageUseCaseImpl(chatRepository: repository)
        self.uploadChatFilesUseCase = UploadChatFilesUseCaseImpl(chatRepository: repository)
    }
    
    public var body: some View {
        VStack {
            Text("글씨 테스트")
                .font(.custom(.jalnan(.title1)))
                .padding(.vertical, .xLarge)
            
            Button {
                Task {
                    do {
                        let data = UIImage(systemName: "star")?.jpegData(compressionQuality: 0.8)
                        guard let data else { return }
                        let response = try await uploadChatFilesUseCase.execute(roomId: "694256de0d0a7a65b929e3db", files: [
                            (data, .jpeg)
                        ]) { progress in
                            print(progress)
                        }
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
