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
    let createCommentUseCase: CreateCommentUseCase
    let editCommentUseCase: EditCommentUseCase
    let deleteCommentUseCase: DeleteCommentUseCase

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
        self.createCommentUseCase = CreateCommentUseCaseImpl(postRepository: postRepository)
        self.editCommentUseCase = EditCommentUseCaseImpl(postRepository: postRepository)
        self.deleteCommentUseCase = DeleteCommentUseCaseImpl(postRepository: postRepository)
    }
    
    public var body: some View {
        VStack {
            Text("글씨 테스트")
                .font(.custom(.jalnan(.title1)))
                .padding(.vertical, .xLarge)
            
            Button {
                Task {
                    do {
                        let response = try await deleteCommentUseCase.execute(postId: "69418edc41c87a75edccc2e6", commentId: "694240a50d0a7a65b929e2b4")
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
