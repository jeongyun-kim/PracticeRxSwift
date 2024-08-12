//
//  MovieViewModel.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 8/8/24.
//

import Foundation
import RxSwift
import RxCocoa

final class MovieViewModel: ViewModel {
    private let disposeBag = DisposeBag()
    
    struct Input {
        let searchBtnTapped: Observable<ControlProperty<String>.Element>
        let cancelBtnTapped: ControlEvent<Void>
    }
    
    struct Output {
        let movieList: Driver<[DailyBoxOfficeList]>
        let errorMessage: Driver<String>
    }
    
    func transform(_ input: Input) -> Output {
        let movieList = PublishRelay<[DailyBoxOfficeList]>()
        let errorMessage = PublishRelay<String>()
        
        // (1) flatMap을 사용하지 않았을 때
//        input.searchBtnTapped
//            .throttle(.seconds(3), scheduler: MainScheduler.instance) // 3초에 한 번만 가능
//            .distinctUntilChanged() // 키워드 바뀌지않았으면 실행 X
//            .map {
//                if let value = Int($0) {
//                    return value
//                } else {
//                    return 20240807
//                }
//            }
//            .map { "\($0)" }
//            .map { MovieNetwork.shared.fetchMovieResults($0) } // => Observalbe<Movie>
//            .debug("2")
//            .subscribe(with: self) { owner, value in // searchBtnTapped를 구독 시작해서
//                value // Observable<Movie>의 Observable 껍데기 버리기 위해서 내부에서 또 구독
//                    .debug("3") // 만약 네트워크 통신 이후에 complete 해주지않으면 스트림이 계속해서 유지되면서 새로운 스트림이 생겨남
//                    .subscribe(with: self) { owner, movie in // => 여기가 진짜 Movie Data
//                        // 그렇게 받아온 리스트 Output으로 던져주기
//                        movieList.accept(movie.boxOfficeResult.dailyBoxOfficeList)
//                    }.disposed(by: owner.disposeBag)
//            }.disposed(by: disposeBag)
//        
       
        // (2) flatMap을 사용했을 때
//        input.searchBtnTapped
//            .throttle(.seconds(3), scheduler: MainScheduler.instance) // 3초에 한 번만 가능
//            .distinctUntilChanged() // 키워드 바뀌지않았으면 실행 X
//            .map {
//                if let value = Int($0) {
//                    return value
//                } else {
//                    return 20240807
//                }
//            }
//            .map { "\($0)" }
//            .debug("OxO")
//            .flatMap { MovieNetwork.shared.fetchMovieResults($0) } // Observable 껍데기 던지고 나옴
//            .debug("O^O")
//            .subscribe(with: self) { owner, movie in // => Movie
//                movieList.accept(movie.boxOfficeResult.dailyBoxOfficeList)
//            }.disposed(by: disposeBag)
//
        
        // (3) Single<Result>로 에러 핸들링
        input.searchBtnTapped
            .throttle(.seconds(3), scheduler: MainScheduler.instance)
            .flatMap { MovieNetwork.shared.fetchMovieResultsSingleRT($0) }
            .debug("OXO")
            .bind { result in
                switch result {
                case.success(let value):
                    movieList.accept(value.boxOfficeResult.dailyBoxOfficeList)
                case .failure(let error):
                    errorMessage.accept("검색결과를 가져오지 못했습니다")
                }
            }.disposed(by: disposeBag)
        
        input.cancelBtnTapped
            .map { [] }
            .bind(to: movieList)
            .disposed(by: disposeBag)
        
        let output = Output(movieList: movieList.asDriver(onErrorJustReturn: []), errorMessage: errorMessage.asDriver(onErrorJustReturn: ""))
        return output
    }
}
