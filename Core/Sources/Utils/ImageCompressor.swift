//
//  ImageCompressor.swift
//  Core
//
//  Created by 김영훈 on 1/7/26.
//

import UIKit

public struct ImageCompressor {
    /// 이미지 데이터를 최대 크기 제한에 맞게 압축합니다.
    ///
    /// - Parameters:
    ///   - data: 원본 이미지 데이터
    ///   - maxSizeInMB: 최대 크기 제한 (MB 단위, 기본값: 1MB)
    ///   - maxDimension: 이미지의 최대 가로/세로 크기 (기본값: 1920px)
    /// - Returns: 압축된 이미지 데이터. 압축 실패 시 nil 반환
    public static func compress(
        _ data: Data,
        maxSizeInMB: Double = 1.0,
        maxDimension: CGFloat = 1920
    ) -> Data? {
        guard let image = UIImage(data: data) else {
            return nil
        }

        // 1. 이미지 크기 조절 (너무 큰 이미지는 리사이징)
        let resizedImage = resize(image, maxDimension: maxDimension)

        // 2. 압축률을 조정하며 최대 크기 이하로 압축
        return compressToLimit(resizedImage, maxSizeInBytes: Int(maxSizeInMB * 1024 * 1024))
    }

    /// 이미지를 최대 크기에 맞게 리사이징합니다.
    private static func resize(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size

        // 이미 충분히 작으면 리사이징 불필요
        if size.width <= maxDimension && size.height <= maxDimension {
            return image
        }

        // 비율 유지하며 리사이징
        let aspectRatio = size.width / size.height
        var newSize: CGSize

        if size.width > size.height {
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    /// 이미지를 목표 크기 이하로 압축합니다.
    private static func compressToLimit(_ image: UIImage, maxSizeInBytes: Int) -> Data? {
        var compression: CGFloat = 1.0
        let step: CGFloat = 0.1

        guard var imageData = image.jpegData(compressionQuality: compression) else {
            return nil
        }

        // 이미 크기가 작으면 그대로 반환
        if imageData.count <= maxSizeInBytes {
            return imageData
        }

        // 압축률을 점진적으로 낮추면서 목표 크기 달성
        while imageData.count > maxSizeInBytes && compression > 0.1 {
            compression -= step

            guard let compressedData = image.jpegData(compressionQuality: compression) else {
                break
            }

            imageData = compressedData
        }

        // 최소 압축률(0.1)에서도 크기를 초과하는 경우
        if imageData.count > maxSizeInBytes {
            // 이미지를 더 작게 리사이징하고 재시도
            let smallerImage = resize(image, maxDimension: 1280)
            return compressToLimit(smallerImage, maxSizeInBytes: maxSizeInBytes)
        }

        return imageData
    }
}
