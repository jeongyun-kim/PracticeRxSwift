//
//  URLRequestManager.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 8/11/24.
//

import Foundation
import Alamofire

enum URLRequestManager {
    case search(query: Search)
}

extension URLRequestManager: TargetType {
    var baseURL: String {
        return UnsplashAPI.base
    }
    
    var endPoint: String {
        return "/search/photos"
    }
    
    
    var method: HTTPMethod {
        return .get
    }

    var params: [String : String] {
        switch self {
        case .search(let query):
            return ["client_id": UnsplashAPI.key, "query": query.keyword, "per_page": "20", "page": "\(query.page)", "order_by": query.sort]
        }
    }
}
