//
//  PostWriteFeature.swift
//  Presentation
//
//  Created by 김영훈 on 1/5/26.
//

import Foundation
import Domain
import Core
import ComposableArchitecture

@Reducer
struct PostWriteFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        var selectedRestaurant: Restaurant?
        var restaurantSearchText = ""
        var restaurantSearchResults: [Restaurant] = []
        var isSearching = false
        var title = ""
        var content = ""
        var selectedMediaData: [(Data, MediaType)] = []
        var uploadedMediaURLs: [String] = []
        var isUploading = false
        var isSaving = false
        var isShowingMediaPicker = false
        let maxMedia = 5

        var canAddMoreMedia: Bool {
            selectedMediaData.count + uploadedMediaURLs.count < maxMedia
        }

        var canSave: Bool {
            selectedRestaurant != nil &&
            !title.isEmpty &&
            !content.isEmpty &&
            !isUploading &&
            !isSaving
        }
        
        var maxSelectionCount: Int {
            maxMedia - selectedMediaData.count - uploadedMediaURLs.count
        }

        @Presents var alert: AlertState<PostWriteFeature.Alert>?
    }

    // MARK: - Action
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case restaurantSearchTextChanged(String)
        case restaurantSearchSubmitted
        case restaurantSearchResult([Restaurant])
        case restaurantSearchFailed(Error)
        case restaurantSelected(Restaurant)
        case addMediaTapped
        case mediaSelected([(Data, MediaType)])
        case removeMedia(Int)
        case removeUploadedMedia(Int)
        case saveTapped
        case uploadMedia
        case uploadSuccess([String])
        case uploadFailed(Error)
        case createPost
        case postCreated(PostDetail)
        case postFailed(Error)
        case alert(PresentationAction<PostWriteFeature.Alert>)
    }

    // MARK: - Dependencies
    @Dependency(\.searchRestaurants) var searchRestaurantsUseCase
    @Dependency(\.createPost) var createPostUseCase
    @Dependency(\.uploadPostFiles) var uploadPostFilesUseCase
    @Dependency(\.dismiss) var dismiss

    // MARK: - Body
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none

            case let .restaurantSearchTextChanged(text):
                state.restaurantSearchText = text
                return .none

            case .restaurantSearchSubmitted:
                guard !state.restaurantSearchText.isEmpty, !state.isSearching else {
                    return .none
                }
                state.isSearching = true

                let searchText = state.restaurantSearchText

                return .run { send in
                    do {
                        let restaurants = try await searchRestaurantsUseCase.execute(name: searchText)
                        await send(.restaurantSearchResult(restaurants))
                    } catch {
                        await send(.restaurantSearchFailed(error))
                    }
                }

            case let .restaurantSearchResult(restaurants):
                state.isSearching = false
                state.restaurantSearchResults = restaurants
                return .none

            case let .restaurantSearchFailed(error):
                state.isSearching = false
                state.alert = AlertState {
                    TextState("식당 검색 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case let .restaurantSelected(restaurant):
                state.selectedRestaurant = restaurant
                state.restaurantSearchText = ""
                state.restaurantSearchResults = []
                return .none

            case .addMediaTapped:
                state.isShowingMediaPicker = true
                return .none

            case let .mediaSelected(dataArray):
                state.selectedMediaData.append(contentsOf: dataArray)
                state.isShowingMediaPicker = false
                return .none

            case let .removeMedia(index):
                guard index < state.selectedMediaData.count else { return .none }
                state.selectedMediaData.remove(at: index)
                return .none

            case let .removeUploadedMedia(index):
                guard index < state.uploadedMediaURLs.count else { return .none }
                state.uploadedMediaURLs.remove(at: index)
                return .none

            case .saveTapped:
                if state.selectedMediaData.isEmpty {
                    return .send(.createPost)
                } else {
                    return .send(.uploadMedia)
                }

            case .uploadMedia:
                state.isUploading = true
                let dataArray = state.selectedMediaData

                return .run { send in
                    do {
                        let urls = try await uploadPostFilesUseCase.execute(
                            datas: dataArray,
                            onProgress: nil
                        )
                        await send(.uploadSuccess(urls))
                    } catch {
                        await send(.uploadFailed(error))
                    }
                }

            case let .uploadSuccess(urls):
                state.isUploading = false
                state.uploadedMediaURLs.append(contentsOf: urls)
                state.selectedMediaData = []
                return .send(.createPost)

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

            case .createPost:
                guard let restaurant = state.selectedRestaurant else {
                    return .none
                }
                state.isSaving = true
                
                let request = CreatePostRequest(
                    category: restaurant.category,
                    title: state.title,
                    content: state.content,
                    restaurantId: restaurant.restaurantId,
                    latitude: restaurant.geolocation.latitude,
                    longitude: restaurant.geolocation.longitude,
                    files: state.uploadedMediaURLs
                )
                
                return .run { send in
                    do {
                        let postDetail = try await createPostUseCase.execute(request: request)
                        await send(.postCreated(postDetail))
                    } catch {
                        await send(.postFailed(error))
                    }
                }

            case .postCreated:
                state.isSaving = false
                return .run { _ in
                    await dismiss()
                }

            case let .postFailed(error):
                state.isSaving = false
                state.alert = AlertState {
                    TextState("포스트 작성 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case .alert:
                return .none
            case .binding:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }

    enum Alert: Sendable {}
}
