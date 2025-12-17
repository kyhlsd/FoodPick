//
//  FilesResponse.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

public struct FilesResponse {
    public let files: [String]
    
    public init(files: [String]) {
        self.files = files
    }
}
