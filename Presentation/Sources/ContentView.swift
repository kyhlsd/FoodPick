import SwiftUI
import Data
import Domain
import Core

public struct ContentView: View {
    let postRepository: PostRepository
    let uploadFilesUseCase: UploadFilesUseCase
    let createPostUseCase: CreatePostUseCase
    let fetchPostsUseCase: FetchPostsUseCase
    let searchPostsUseCase: SearchPostsUseCase
    let fetchPostDetailUseCase: FetchPostDetailUseCase
    let editPostUseCase: EditPostUseCase
    let deletePostUseCase: DeletePostUseCase
    let likePostUseCase: LikePostUseCase
    let fetchUserPostsUseCase: FetchUserPostsUseCase
    let fetchMyLikedPostsUseCase: FetchMyLikedPostsUseCase

    public init() {
        let postRepository = DefaultPostRepositoryImpl()
        self.postRepository = postRepository
        self.uploadFilesUseCase = UploadFilesUseCaseImpl(postRepository: postRepository)
        self.createPostUseCase = CreatePostUseCaseImpl(postRepository: postRepository)
        self.fetchPostsUseCase = FetchPostsUseCaseImpl(postRepository: postRepository)
        self.searchPostsUseCase = SearchPostsUseCaseImpl(postRepository: postRepository)
        self.fetchPostDetailUseCase = FetchPostDetailUseCaseImpl(postRepository: postRepository)
        self.editPostUseCase = EditPostUseCaseImpl(postRepository: postRepository)
        self.deletePostUseCase = DeletePostUseCaseImpl(postRepository: postRepository)
        self.likePostUseCase = LikePostUseCaseImpl(postRepository: postRepository)
        self.fetchUserPostsUseCase = FetchUserPostsUseCaseImpl(postRepository: postRepository)
        self.fetchMyLikedPostsUseCase = FetchMyLikedPostsUseCaseImpl(postRepository: postRepository)
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
                        let response = try await uploadFilesUseCase.execute(datas: [
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
