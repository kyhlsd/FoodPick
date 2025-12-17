//
//  ReviewRouter.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Alamofire
import Core

enum ReviewRouter {
    case files(id: String, files: [(Data, MediaType)])
    case review(id: String, dto: ReviewRequestDTO)
    case reviewList(id: String, dto: ReviewPageRequestDTO)
    case detail(storeId: String, reviewId: String)
    case edit(storeId: String, reviewId: String, dto: EditReviewRequestDTO)
    case delete(storeId: String, reviewId: String)
    case statistics(id: String)
}

extension ReviewRouter: Router {
    var method: HTTPMethod {
        switch self {
        case .files, .review:
            return .post
        case .reviewList, .detail, .statistics:
            return .get
        case .edit:
            return .put
        case .delete:
            return .delete
        }
    }
    
    var path: String {
        let base = "/stores"
        switch self {
        case .files(let id, _):
            return base + "/\(id)/reviews/files"
        case .review(let id, _), .reviewList(let id, _):
            return base + "/\(id)/reviews"
        case .detail(let storeId, let reviewId), .edit(let storeId, let reviewId, _),
                .delete(let storeId, let reviewId):
            return base + "/\(storeId)/reviews/\(reviewId)"
        case .statistics(let id):
            return base + "/\(id)/reviews/reviews-ratings"
        }
    }
    
    var body: RequestBody {
        switch self {
        case .files, .reviewList, .detail, .delete, .statistics:
            return .none
        case .review(_, let dto):
            return .encodable(dto)
        case .edit(_, _, let dto):
            return .encodable(dto)
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .reviewList(_, let dto):
            return dto.toQueryItems
        default:
            return []
        }
    }
    
    var headers: HTTPHeaders {
        return HTTPHeader.asHTTPHeaders(HTTPHeader.basic)
    }
    
    var multipartFormData: ((Alamofire.MultipartFormData) -> Void)? {
        switch self {
        case .files(_, let files):
            return { form in
                for (data, mediaType) in files {
                    let fileName = "\(UUID().uuidString).\(mediaType.fileExtension)"
                    form.append(data, withName: "files", fileName: fileName, mimeType: mediaType.mimeType)
                }
            }
        default:
            return nil
        }
    }
    
}
