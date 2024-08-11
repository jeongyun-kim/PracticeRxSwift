//
//  UnsplashNetwork.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 8/11/24.
//

import Foundation
import Alamofire

final class UnsplashNetwork {
    private init() { }
    static let shared = UnsplashNetwork()
    
    func fetchSearchResults<T: Decodable>(of: T.Type, request: URLRequest) {
        AF.request(request)
            .responseDecodable(of: T.self) { respose in
                switch respose.result {
                case .success(let value):
                    print(value)
                case .failure(let error):
                    print(error)
                }
            }
    }
}
