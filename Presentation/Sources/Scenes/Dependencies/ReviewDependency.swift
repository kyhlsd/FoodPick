//
//  ReviewDependency.swift
//  Presentation
//
//  Created by 김영훈 on 12/19/25.
//

import Domain
import Data
import ComposableArchitecture

extension DependencyValues {

    // MARK: - Repository
    var reviewRepository: ReviewRepository {
        get { self[ReviewRepositoryKey.self] }
        set { self[ReviewRepositoryKey.self] = newValue }
    }

    // MARK: - UseCases
    var fetchReviewList: FetchReviewListUseCase {
        get { self[FetchReviewListKey.self] }
        set { self[FetchReviewListKey.self] = newValue }
    }

    var fetchReviewDetail: FetchReviewDetailUseCase {
        get { self[FetchReviewDetailKey.self] }
        set { self[FetchReviewDetailKey.self] = newValue }
    }

    var createReview: CreateReviewUseCase {
        get { self[CreateReviewKey.self] }
        set { self[CreateReviewKey.self] = newValue }
    }

    var editReview: EditReviewUseCase {
        get { self[EditReviewKey.self] }
        set { self[EditReviewKey.self] = newValue }
    }

    var deleteReview: DeleteReviewUseCase {
        get { self[DeleteReviewKey.self] }
        set { self[DeleteReviewKey.self] = newValue }
    }

    var fetchReviewStatistics: FetchReviewStatisticsUseCase {
        get { self[FetchReviewStatisticsKey.self] }
        set { self[FetchReviewStatisticsKey.self] = newValue }
    }

    var uploadReviewFiles: UploadReviewFilesUseCase {
        get { self[UploadReviewFilesKey.self] }
        set { self[UploadReviewFilesKey.self] = newValue }
    }
}

// MARK: - Keys
private enum ReviewRepositoryKey: DependencyKey {
    static let liveValue: ReviewRepository = DefaultReviewRepositoryImpl()
}

private enum FetchReviewListKey: DependencyKey {
    static let liveValue: FetchReviewListUseCase = {
        @Dependency(\.reviewRepository) var reviewRepository
        return FetchReviewListUseCaseImpl(reviewRepository: reviewRepository)
    }()
}

private enum FetchReviewDetailKey: DependencyKey {
    static let liveValue: FetchReviewDetailUseCase = {
        @Dependency(\.reviewRepository) var reviewRepository
        return FetchReviewDetailUseCaseImpl(reviewRepository: reviewRepository)
    }()
}

private enum CreateReviewKey: DependencyKey {
    static let liveValue: CreateReviewUseCase = {
        @Dependency(\.reviewRepository) var reviewRepository
        return CreateReviewUseCaseImpl(reviewRepository: reviewRepository)
    }()
}

private enum EditReviewKey: DependencyKey {
    static let liveValue: EditReviewUseCase = {
        @Dependency(\.reviewRepository) var reviewRepository
        return EditReviewUseCaseImpl(reviewRepository: reviewRepository)
    }()
}

private enum DeleteReviewKey: DependencyKey {
    static let liveValue: DeleteReviewUseCase = {
        @Dependency(\.reviewRepository) var reviewRepository
        return DeleteReviewUseCaseImpl(reviewRepository: reviewRepository)
    }()
}

private enum FetchReviewStatisticsKey: DependencyKey {
    static let liveValue: FetchReviewStatisticsUseCase = {
        @Dependency(\.reviewRepository) var reviewRepository
        return FetchReviewStatisticsUseCaseImpl(reviewRepository: reviewRepository)
    }()
}

private enum UploadReviewFilesKey: DependencyKey {
    static let liveValue: UploadReviewFilesUseCase = {
        @Dependency(\.reviewRepository) var reviewRepository
        return UploadReviewFilesUseCaseImpl(reviewRepository: reviewRepository)
    }()
}
