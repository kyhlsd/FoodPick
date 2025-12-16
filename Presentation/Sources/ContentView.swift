import SwiftUI
import Data
import Domain

public struct ContentView: View {
    let repository: StoreRepository
    let fetchMyLikesUseCase: FetchMyLikesUseCase
    let fetchPopularSearchUseCase: FetchPopularSearchesUseCase
    let fetchPopularStoreUseCase: FetchPopularStoresUseCase
    let fetchReviewsUseCase: FetchReviewsUseCase
    let fetchStoreInfoUseCase: FetchStoreInfoUseCase
    let fetchStoresUseCase: FetchStoresUseCase
    let searchStoresUseCase: SearchStoresUseCase
    let toggleStoreLikeUseCase: ToggleStoreLikeUseCase
    
    public init() {
        let repository = DefaultStoreRepositoryImpl()
        self.repository = repository
        self.fetchMyLikesUseCase = FetchMyLikesUseCaseImpl(storeRepository: repository)
        self.fetchPopularSearchUseCase = FetchPopularSearchesUseCaseImpl(storeRepository: repository)
        self.fetchPopularStoreUseCase = FetchPopularStoresUseCaseImpl(storeRepository: repository)
        self.fetchReviewsUseCase = FetchReviewsUseCaseImpl(storeRepository: repository)
        self.fetchStoresUseCase = FetchStoresUseCaseImpl(storeRepository: repository)
        self.fetchStoreInfoUseCase = FetchStoreInfoUseCaseImpl(storeRepository: repository)
        self.searchStoresUseCase = SearchStoresUseCaseImpl(storeRepository: repository)
        self.toggleStoreLikeUseCase = ToggleStoreLikeUseCaseImpl(storeRepository: repository)
    }
    
    public var body: some View {
        VStack {
            Text("글씨 테스트")
                .font(.custom(.jalnan(.title1)))
                .padding(.vertical, .xLarge)
            
            Button {
                Task {
                    do {
                        let response = try await searchStoresUseCase.execute(name: "새싹")
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
