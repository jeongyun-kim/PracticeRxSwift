//
//  MovieNetwork.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 8/8/24.
//

import Foundation
import RxSwift

private enum NetworkError: Error {
    case invalidURL
    case error
    case invalidResponse
    case invalidData
}

final class MovieNetwork {
    static let shared = MovieNetwork()
    private init() { }
    
    func fetchMovieResults(_ date: String) -> Observable<Movie> {
        // create의 반환값은 Observable<Movie>
        let fetch = Observable<Movie>.create { observer in
            // URL이 유효하지 않다면 에러 이벤트 보내기
            let url = "https://kobis.or.kr/kobisopenapi/webservice/rest/boxoffice/searchDailyBoxOfficeList.json?key=\(MovieAPI.key)&targetDt=\(date)"
            guard let url = URL(string: url) else {
                observer.onError(NetworkError.invalidURL)
                return Disposables.create()
            }
            
            // 네트워크 통신 -> data / response / error
            URLSession.shared.dataTask(with: url) { data, response, error in
                // 통신 중 에러가 왔다면
                if let error {
                    observer.onError(NetworkError.error)
                    return
                }
                
                // 응답이 HTTPURLResponse로 변환했을 때 nil이고 상태코드가 200대가 아니라면
                guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    observer.onError(NetworkError.invalidResponse)
                    return
                }
                
                // 여기서부터는 데이터가 존재할 가능성 O
                // - Movie모델로 변환했을 때 데이터가 있다면 onNext / 없다면 에러 보내기
                if let data, let result = try? JSONDecoder().decode(Movie.self, from: data) {
                    observer.onNext(result)
                    //observer.onCompleted()
                } else {
                    observer.onError(NetworkError.invalidData)
                    return
                }
            }.resume() // URLSession은 실행하기 위해 꼭 resume()
            return Disposables.create()
        }
       
        return fetch
    }
}
