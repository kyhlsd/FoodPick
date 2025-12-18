import SwiftUI
import Data
import Domain
import Core

public struct ContentView: View {
    let repository: BannerRepository
    let useCase: FetchMainBannersUseCase
    public init() {
        self.repository = DefaultBannerRepositoryImpl()
        self.useCase = FetchMainBannersUseCaseImpl(bannerRepository: repository)
    }
    
    public var body: some View {
        VStack {
            Text("글씨 테스트")
                .font(.custom(.jalnan(.title1)))
                .padding(.vertical, .xLarge)
            Text("글씨 테스트")
                .font(.custom(.pretendard(.title1)))
                .padding(.vertical, .xLarge)
            Text("글씨 테스트")
                .font(.system(size: 20))
                .padding(.vertical, .xLarge)
            
            Button {
                Task {
                    do {
                        let response = try await useCase.execute()
//                        print(response)
                    } catch {
//                        print("error: \(error.localizedDescription)")
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
