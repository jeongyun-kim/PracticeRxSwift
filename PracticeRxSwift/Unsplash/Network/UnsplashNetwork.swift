//
//  UnsplashNetwork.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 8/11/24.
//

import Foundation
import Alamofire
import RxSwift

final class UnsplashNetwork {
    private init() { }
    static let shared = UnsplashNetwork()
    
    func fetchSearchResults<T: Decodable>(of: T.Type, request: URLRequest) -> Observable<T> {
        return Observable<T>.create { observer in
            AF.request(request).responseDecodable(of: T.self) { respose in
                switch respose.result {
                case .success(let value):
                    observer.onNext(value)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
}
