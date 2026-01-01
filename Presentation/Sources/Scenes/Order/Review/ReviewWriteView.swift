//
//  ReviewWriteView.swift
//  Presentation
//
//  Created by 김영훈 on 1/1/26.
//

import SwiftUI
import PhotosUI
import Domain
import ComposableArchitecture

struct ReviewWriteView: View {
    let store: StoreOf<ReviewWriteFeature>
    @State private var selectedPhotos: [PhotosPickerItem] = []

    private var navigationTitle: String {
        switch store.mode {
        case .create: return "리뷰 작성"
        case .edit: return "리뷰 수정"
        }
    }

    var body: some View {
        WithPerceptionTracking {
            @Perception.Bindable var store = store

            ScrollView {
                VStack(spacing: AppPadding.large.value) {
                    // 평점 선택
                    RatingSection(
                        rating: store.rating
                    ) {
                        store.send(.ratingTapped($0))
                    }

                    MyDivider()

                    // 사진 선택
                    PhotoSection(
                        imageDataArray: store.selectedImageData,
                        uploadedURLs: store.uploadedImageURLs,
                        canAddMore: store.canAddMorePhotos,
                        onAddPhotoTapped: { store.send(.addPhotoTapped) },
                        onRemovePhoto: { store.send(.removePhoto($0)) }
                    )

                    MyDivider()

                    // 리뷰 내용
                    ContentSection(content: $store.content)
                }
                .padding(.all, .xLarge)
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    SaveButton(
                        isSaving: store.isSaving,
                        isUploading: store.isUploading,
                        canSave: store.canSave
                    ) {
                        store.send(.saveTapped)
                    }
                }
            }
            .sheet(isPresented: $store.isShowingPhotoPicker) {
                PhotosPicker(
                    selection: $selectedPhotos,
                    maxSelectionCount: store.maxPhotos - store.selectedImageData.count - store.uploadedImageURLs.count,
                    matching: .images
                ) {
                    Text("사진 선택")
                }
                .onChange(of: selectedPhotos) {
                    handlePhotoSelection($0)
                }
            }
            .alert($store.scope(state: \.alert, action: \.alert))
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
    
    private func handlePhotoSelection(_ items: [PhotosPickerItem]) {
        Task {
            var dataArray: [Data] = []
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    dataArray.append(data)
                }
            }
            if !dataArray.isEmpty {
                store.send(.photosSelected(dataArray))
            }
            selectedPhotos = []
        }
    }
}

// MARK: - Rating Section
private struct RatingSection: View {
    let rating: Int
    let onRatingTapped: (Int) -> Void

    var body: some View {
        VStack(spacing: AppPadding.medium.value) {
            Text("이 가게에 대한 평가는 어떠신가요?")
                .font(.pretendard(size: .body1, weight: .bold))
                .foregroundStyle(.custom(.gray(.gray90)))

            HStack(spacing: AppPadding.small.value) {
                ForEach(1...5, id: \.self) { index in
                    Button {
                        onRatingTapped(index)
                    } label: {
                        AppIcon.starFill
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(.custom(
                                index <= rating
                                    ? .brand(.brightForsythia)
                                    : .gray(.gray30)
                            ))
                    }
                }
            }
        }
    }
}

// MARK: - Photo Section
private struct PhotoSection: View {
    let imageDataArray: [Data]
    let uploadedURLs: [String]
    let canAddMore: Bool
    let onAddPhotoTapped: () -> Void
    let onRemovePhoto: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppPadding.medium.value) {
            HStack {
                Text("사진")
                    .font(.pretendard(size: .body1, weight: .bold))
                    .foregroundStyle(.custom(.gray(.gray90)))

                Text("(\(imageDataArray.count + uploadedURLs.count)/5)")
                    .font(.pretendard(size: .body2, weight: .medium))
                    .foregroundStyle(.custom(.gray(.gray60)))

                Spacer()
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppPadding.medium.value) {
                    // 사진 추가 버튼
                    if canAddMore {
                        Button {
                            onAddPhotoTapped()
                        } label: {
                            VStack(spacing: AppPadding.tiny.value) {
                                AppIcon.photo
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundStyle(.custom(.gray(.gray60)))

                                Text("사진 추가")
                                    .font(.pretendard(size: .caption2, weight: .medium))
                                    .foregroundStyle(.custom(.gray(.gray60)))
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
                    }

                    // 업로드된 이미지 (편집 모드일 때)
                    ForEach(uploadedURLs, id: \.self) { url in
                        ZStack(alignment: .topTrailing) {
                            AuthenticatedImage(imagePath: url)
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                            Button {
                                // uploadedURLs 제거는 별도 로직 필요
                            } label: {
                                AppIcon.xmarkCircle
                                    .resizable()
                                    .frame(width: 12, height: 12)
                                    .foregroundStyle(.white)
                            }
                            .padding(4)
                        }
                    }

                    // 선택된 이미지
                    ForEach(Array(imageDataArray.enumerated()), id: \.offset) { index, data in
                        ZStack(alignment: .topTrailing) {
                            if let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }

                            Button {
                                onRemovePhoto(index)
                            } label: {
                                AppIcon.xmarkCircle
                                    .resizable()
                                    .frame(width: 12, height: 12)
                                    .foregroundStyle(.white)
                            }
                            .padding(4)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Content Section
private struct ContentSection: View {
    @Binding var content: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppPadding.medium.value) {
            Text("리뷰 내용")
                .font(.pretendard(size: .body1, weight: .bold))
                .foregroundStyle(.custom(.gray(.gray90)))

            TextField("리뷰를 작성해주세요", text: $content, axis: .vertical)
                .font(.pretendard(size: .body2, weight: .regular))
                .foregroundStyle(.custom(.gray(.gray90)))
                .lineLimit(10...20)
                .padding(.all, AppPadding.medium.value)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.custom(.gray(.gray15)))
                )
        }
    }
}

// MARK: - Save Button
private struct SaveButton: View {
    let isSaving: Bool
    let isUploading: Bool
    let canSave: Bool
    let onSave: () -> Void

    var body: some View {
        Button {
            onSave()
        } label: {
            if isSaving || isUploading {
                ProgressView()
            } else {
                Text("완료")
                    .font(.pretendard(size: .body2, weight: .bold))
                    .foregroundStyle(
                        canSave
                            ? Color.custom(.brand(.blackSprout))
                            : Color.custom(.gray(.gray45))
                    )
            }
        }
        .disabled(!canSave)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ReviewWriteView(
            store: Store(
                initialState: ReviewWriteFeature.State(
                    mode: .create(restaurantId: "1", orderCode: "A1234")
                )
            ) {
                ReviewWriteFeature()
            }
        )
    }
}
