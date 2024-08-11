//
//  SearchResults.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 8/11/24.
//

import Foundation

struct SearchResults: Decodable {
    let total: Int
    let totalPages: Int
    let results: [ReceivedPhoto]
    
    enum CodingKeys: String, CodingKey {
        case total, results
        case totalPages = "total_pages"
    }
}

struct ReceivedPhoto: Decodable, Hashable {
    let id: String
    let created_at: String
    let width: Int
    let height: Int
    let color: String
    let likes: Int
    let user: Photographer
    let urls: PhotoURL
}

struct Photographer: Decodable, Hashable {
    let name: String
    let profile_image: PhotographerProfileImage
}

struct PhotographerProfileImage: Decodable, Hashable {
    let small: String
    let medium: String
    let large: String
}

struct PhotoURL: Decodable, Hashable {
    let raw: String
    let small: String
    let thumb: String
}
