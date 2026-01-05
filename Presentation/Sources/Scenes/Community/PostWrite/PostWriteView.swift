//
//  PostWriteView.swift
//  Presentation
//
//  Created by 김영훈 on 1/5/26.
//

import SwiftUI
import PhotosUI
import Domain
import Core
import ComposableArchitecture

struct PostWriteView: View {
    let store: StoreOf<PostWriteFeature>
    @State private var selectedMedia: [PhotosPickerItem] = []

    var body: some View {
        WithPerceptionTracking {
            @Perception.Bindable var store = store
            
            ScrollView {
                VStack(spacing: AppPadding.large.value) {
                    // 식당 검색 및 선택
                    RestaurantSearchSection(store: store)
                    
                    if store.selectedRestaurant != nil {
                        // 포스트 본문 입력
                        VStack(spacing: AppPadding.large.value) {
                            
                            MyDivider()
                            
                            // 제목
                            TitleInputField(content: $store.title)
                            
                            MyDivider()
                            
                            // 미디어 선택
                            MediaGridSection(store: store)
                            
                            MyDivider()
                            
                            // 본문
                            ContentInputField(content: $store.content)
                        }
                    }
                    
                    Spacer(minLength: 110)
                }
                .padding(.horizontal, .xLarge)
            }
            .hideKeyboardOnTap()
            .navigationTitle("포스트 작성")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    SaveButton(store: store)
                }
            }
            .photosPicker(
                isPresented: $store.isShowingMediaPicker,
                selection: $selectedMedia,
                maxSelectionCount: store.maxSelectionCount,
                matching: .any(of: [.images, .videos])
            )
            .onChange(of: selectedMedia) {
                handleMediaSelection($0)
            }
            .onAppear {
                store.send(.onAppear)
            }
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }

    private func handleMediaSelection(_ items: [PhotosPickerItem]) {
        Task {
            var dataArray: [(Data, MediaType)] = []
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data),
                       let jpegData = uiImage.jpegData(compressionQuality: 0.8) {
                        dataArray.append((jpegData, .jpeg))
                    } else if item.supportedContentTypes.contains(where: { $0.conforms(to: .movie) }) {
                        dataArray.append((data, .mp4))
                    }
                }
            }
            if !dataArray.isEmpty { store.send(.mediaSelected(dataArray)) }
            selectedMedia = []
        }
    }
}

private struct RestaurantSearchSection: View {
    @Perception.Bindable var store: StoreOf<PostWriteFeature>
    
    var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: AppPadding.medium.value) {
                Text("식당")
                    .font(.pretendard(size: .body2, weight: .bold))
                
                if let restaurant = store.selectedRestaurant {
                    HStack(spacing: AppPadding.small.value) {
                        AuthenticatedImage(imagePath: restaurant.restaurantImageURLs.first)
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        VStack(alignment: .leading, spacing: AppPadding.tiny.value) {
                            Text(restaurant.name).font(.pretendard(size: .body2, weight: .semiBold))
                            
                            Text(restaurant.category.rawValue)
                                .font(.pretendard(size: .caption1, weight: .regular))
                                .foregroundStyle(.custom(.gray(.gray60)))
                        }
                        
                        Spacer()
                    }
                    .padding(.all, AppPadding.medium.value)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.custom(.brand(.brightSprout)))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.custom(.brand(.deepSprout)), lineWidth: 1)
                    )
                } else {
                    MySearchBar(text: $store.restaurantSearchText.sending(\.restaurantSearchTextChanged)) {
                        store.send(.restaurantSearchSubmitted)
                    }
                    
                    if store.isSearching {
                        ProgressView().frame(maxWidth: .infinity).padding()
                    } else {
                        ForEach(store.restaurantSearchResults, id: \.restaurantId) { restaurant in
                            Button {
                                store.send(.restaurantSelected(restaurant))
                            } label: {
                                HStack {
                                    AuthenticatedImage(imagePath: restaurant.restaurantImageURLs.first)
                                        .frame(width: 40, height: 40)
                                        .clipShape(
                                            RoundedRectangle(cornerRadius: 4)
                                        )
                                    
                                    Text(restaurant.name)
                                        .font(.pretendard(size: .body2, weight: .medium))
                                    
                                    Spacer()
                                }
                                .padding(.all, AppPadding.small.value)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.custom(.gray(.gray15)))
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}

private struct TitleInputField: View {
    @Binding var content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppPadding.medium.value) {
            Text("제목")
                .font(.pretendard(size: .body2, weight: .bold))
                .foregroundStyle(.custom(.gray(.gray90)))

            TextField("제목을 입력해주세요", text: $content, axis: .vertical)
                .font(.pretendard(size: .body2, weight: .regular))
                .foregroundStyle(.custom(.gray(.gray90)))
                .padding(.all, AppPadding.medium.value)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.custom(.gray(.gray15)))
                )
        }
    }
}

private struct ContentInputField: View {
    @Binding var content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppPadding.medium.value) {
            Text("내용")
                .font(.pretendard(size: .body2, weight: .bold))
                .foregroundStyle(.custom(.gray(.gray90)))

            TextField("내용을 입력해주세요", text: $content, axis: .vertical)
                .font(.pretendard(size: .body2, weight: .regular))
                .foregroundStyle(.custom(.gray(.gray90)))
                .lineLimit(10...20)
                .lineSpacing(4)
                .padding(.all, AppPadding.medium.value)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.custom(.gray(.gray15)))
                )
        }
    }
}

private struct MediaGridSection: View {
    let store: StoreOf<PostWriteFeature>
    
    var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: AppPadding.medium.value) {
                HStack {
                    Text("사진/영상").font(.pretendard(size: .body2, weight: .bold))
                    
                    Text("(\(store.selectedMediaData.count + store.uploadedMediaURLs.count)/5)")
                        .font(.pretendard(size: .body2, weight: .medium))
                        .foregroundStyle(.custom(.gray(.gray60)))
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppPadding.medium.value) {
                        if store.canAddMoreMedia {
                            Button { store.send(.addMediaTapped) } label: {
                                VStack(spacing: AppPadding.tiny.value) {
                                    AppIcon.photo
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                    
                                    Text("추가")
                                        .font(.pretendard(size: .caption2, weight: .medium))
                                }
                                .frame(width: 100, height: 100)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.custom(.gray(.gray15)))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(.custom(.gray(.gray30)), lineWidth: 1)
                                )
                            }
                            .foregroundStyle(.custom(.gray(.gray60)))
                        }
                        
                        // 업로드된 미디어 & 새로 선택한 미디어
                        ForEach(Array(store.uploadedMediaURLs.enumerated()), id: \.offset) { index, url in
                            MediaThumbnail(imagePath: url) { store.send(.removeUploadedMedia(index))
                            }
                        }
                        ForEach(Array(store.selectedMediaData.enumerated()), id: \.offset) { index, item in
                            MediaThumbnail(data: item.0, type: item.1) { store.send(.removeMedia(index))
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct MediaThumbnail: View {
    var imagePath: String?
    var data: Data?
    var type: MediaType?
    let onRemove: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let imagePath {
                    AuthenticatedImage(imagePath: imagePath)
                } else if let data, let type {
                    if type.isImage, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                    } else {
                        ZStack {
                            Color.custom(.gray(.gray30))
                            
                            AppIcon.playCircle
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundStyle(.custom(.gray(.gray0)))
                        }
                    }
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(
                RoundedRectangle(cornerRadius: 8)
            )
            
            Button(action: onRemove) {
                AppIcon.xmarkCircle
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.custom(.gray(.gray0)))
            }
            .padding(4)
        }
    }
}

private struct SaveButton: View {
    let store: StoreOf<PostWriteFeature>
    
    var body: some View {
        WithPerceptionTracking {
            Button {
                store.send(.saveTapped)
            } label: {
                if store.isSaving || store.isUploading {
                    ProgressView()
                } else {
                    Text("완료")
                        .font(.pretendard(size: .body2, weight: .bold))
                        .foregroundStyle(store.canSave
                                         ? .custom(.brand(.blackSprout))
                                         : .custom(.gray(.gray45))
                        )
                }
            }
            .disabled(!store.canSave)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        PostWriteView(
            store: Store(
                initialState: PostWriteFeature.State()
            ) {
                PostWriteFeature()
            }
        )
    }
}
