//
//  ReviewWriteFeature.swift
//  Presentation
//
//  Created by 김영훈 on 1/1/26.
//

import Foundation
import Domain
import Core
import ComposableArchitecture

@Reducer
struct ReviewWriteFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        let mode: Mode
        var rating = 0
        var content = ""
        var selectedImageData: [Data] = []
        var uploadedImageURLs: [String] = []
        var isUploading = false
        var isSaving = false
        var isLoadingReview = false
        var isShowingPhotoPicker = false

        @Presents var alert: AlertState<ReviewWriteFeature.Alert>?

        var canSave: Bool {
            rating > 0 && !content.isEmpty && !isSaving && !isUploading
        }

        var maxPhotos = 5

        var canAddMorePhotos: Bool {
            selectedImageData.count + uploadedImageURLs.count < maxPhotos
        }

        enum Mode: Sendable {
            case create(restaurantId: String, orderCode: String)
            case edit(restaurantId: String, reviewId: String)
        }
    }

    // MARK: - Action
    enum Action: BindableAction {
        case onAppear
        case binding(BindingAction<State>)
        case addPhotoTapped
        case photosSelected([Data])
        case removePhoto(Int)
        case removeUploadedImage(Int)
        case ratingTapped(Int)
        case saveTapped
        case uploadPhotos
        case photosUploaded([String])
        case uploadFailed(Error)
        case createReview
        case editReview
        case reviewSaved
        case reviewSaveFailed(Error)
        case fetchReviewDetail
        case reviewDetailLoaded(ReviewResponse)
        case reviewDetailFailed(Error)
        case alert(PresentationAction<ReviewWriteFeature.Alert>)
    }

    // MARK: - Dependencies
    @Dependency(\.createReview) var createReviewUseCase
    @Dependency(\.editReview) var editReviewUseCase
    @Dependency(\.uploadReviewFiles) var uploadReviewFilesUseCase
    @Dependency(\.fetchReviewDetail) var fetchReviewDetailUseCase
    @Dependency(\.dismiss) var dismiss

    // MARK: - Body
    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .onAppear:
                if case .edit = state.mode {
                    return .send(.fetchReviewDetail)
                }
                return .none

            case .addPhotoTapped:
                guard state.canAddMorePhotos else { return .none }
                state.isShowingPhotoPicker = true
                return .none

            case let .photosSelected(dataArray):
                state.isShowingPhotoPicker = false
                let availableSlots = state.maxPhotos - state.selectedImageData.count - state.uploadedImageURLs.count
                let dataToAdd = Array(dataArray.prefix(availableSlots))
                state.selectedImageData.append(contentsOf: dataToAdd)
                return .none

            case let .removePhoto(index):
                guard index < state.selectedImageData.count else { return .none }
                state.selectedImageData.remove(at: index)
                return .none

            case let .removeUploadedImage(index):
                guard index < state.uploadedImageURLs.count else { return .none }
                state.uploadedImageURLs.remove(at: index)
                return .none

            case let .ratingTapped(rating):
                state.rating = rating
                return .none

            case .saveTapped:
                guard state.canSave else { return .none }

                if !state.selectedImageData.isEmpty {
                    return .send(.uploadPhotos)
                } else {
                    switch state.mode {
                    case .create:
                        return .send(.createReview)
                    case .edit:
                        return .send(.editReview)
                    }
                }

            case .uploadPhotos:
                state.isUploading = true

                return .run { [imageData = state.selectedImageData, mode = state.mode] send in
                    do {
                        let restaurantId: String
                        switch mode {
                        case .create(let id, _), .edit(let id, _):
                            restaurantId = id
                        }

                        let files = imageData.map { data in
                            (data, MediaType.jpeg)
                        }

                        let urls = try await uploadReviewFilesUseCase.execute(
                            restaurantId: restaurantId,
                            files: files
                        )
                        await send(.photosUploaded(urls))
                    } catch {
                        await send(.uploadFailed(error))
                    }
                }

            case let .photosUploaded(urls):
                state.isUploading = false
                state.uploadedImageURLs.append(contentsOf: urls)

                switch state.mode {
                case .create:
                    return .send(.createReview)
                case .edit:
                    return .send(.editReview)
                }

            case let .uploadFailed(error):
                state.isUploading = false
                state.alert = AlertState {
                    TextState("사진 업로드 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case .createReview:
                guard case .create(let restaurantId, let orderCode) = state.mode else {
                    return .none
                }
                state.isSaving = true

                return .run { [rating = state.rating, content = state.content, urls = state.uploadedImageURLs] send in
                    do {
                        let request = ReviewRequest(
                            content: content,
                            rating: rating,
                            reviewImageURLs: urls,
                            orderCode: orderCode
                        )
                        _ = try await createReviewUseCase.execute(
                            restaurantId: restaurantId,
                            request: request
                        )
                        await send(.reviewSaved)
                    } catch {
                        await send(.reviewSaveFailed(error))
                    }
                }

            case .editReview:
                guard case .edit(let restaurantId, let reviewId) = state.mode else {
                    return .none
                }
                state.isSaving = true

                return .run { [rating = state.rating, content = state.content, urls = state.uploadedImageURLs] send in
                    do {
                        let request = EditReviewRequest(
                            content: content,
                            rating: rating,
                            reviewImageURLs: urls.isEmpty ? nil : urls
                        )
                        _ = try await editReviewUseCase.execute(
                            restaurantId: restaurantId,
                            reviewId: reviewId,
                            request: request
                        )
                        await send(.reviewSaved)
                    } catch {
                        await send(.reviewSaveFailed(error))
                    }
                }

            case .reviewSaved:
                state.isSaving = false
                return .run { _ in await dismiss() }

            case let .reviewSaveFailed(error):
                state.isSaving = false
                state.alert = AlertState {
                    TextState("리뷰 저장 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case .fetchReviewDetail:
                guard case .edit(let restaurantId, let reviewId) = state.mode else {
                    return .none
                }
                state.isLoadingReview = true

                return .run { send in
                    do {
                        let review = try await fetchReviewDetailUseCase.execute(
                            restaurantId: restaurantId,
                            reviewId: reviewId
                        )
                        await send(.reviewDetailLoaded(review))
                    } catch {
                        await send(.reviewDetailFailed(error))
                    }
                }

            case let .reviewDetailLoaded(review):
                state.isLoadingReview = false
                state.rating = review.rating
                state.content = review.content
                state.uploadedImageURLs = review.reviewImageURLs
                return .none

            case let .reviewDetailFailed(error):
                state.isLoadingReview = false
                state.alert = AlertState {
                    TextState("리뷰 불러오기 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case .binding, .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }

    enum Alert: Sendable {}
}
