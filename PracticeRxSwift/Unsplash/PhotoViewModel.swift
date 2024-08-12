//
//  PhotoViewModel.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 8/11/24.
//

import Foundation
import RxSwift
import RxCocoa

final class PhotoViewModel: ViewModel {
    private let disposeBag = DisposeBag()
    
    struct Input {
        let searchBtnTapped: Observable<ControlProperty<String>.Element>
        let prefetchIdxs: ControlEvent<[IndexPath]>
    }
    
    struct Output {
        let searchResults: BehaviorRelay<[ReceivedPhoto]>
        let scrollToTop: BehaviorRelay<Bool>
        let errorMessage: PublishRelay<String>
    }
    
    private var keyword = ""
    private var page = 1
    private let sort = "relevant"
    private var totalPages = 0
    
    func transform(_ input: Input) -> Output {
        let list: BehaviorRelay<[ReceivedPhoto]> = BehaviorRelay(value: [])
        let scroll = BehaviorRelay(value: false)
        let errorMessage = PublishRelay<String>()

        // 검색 버튼 눌렀을 때
        input.searchBtnTapped
            .map { $0.lowercased() }
            .distinctUntilChanged()
            .throttle(.seconds(5), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, keyword in
                owner.page = 1
                owner.fetch(keyword: keyword, handler: { value in
                    owner.keyword = keyword
                    owner.totalPages = value.totalPages
                    list.accept(value.results)
                    // 새로운 결과 받아올 때 스크롤 맨위로
                    guard list.value.count > 0 else { return scroll.accept(false) }
                    scroll.accept(true)
                }, errorMessage: errorMessage)
            }.disposed(by: disposeBag)

        // 페이지네이션
        input.prefetchIdxs
            .compactMap { $0.last }
            .map { $0.row == list.value.count - 3 && self.page < self.totalPages }
            .filter { $0 }
            .bind(with: self) { owner, value in
                owner.page += 1
                owner.fetch(keyword: owner.keyword, handler: { value in
                    var currentList = list.value
                    currentList.append(contentsOf: value.results)
                    list.accept(currentList)
                }, errorMessage: errorMessage)
            }.disposed(by: disposeBag)
        
        return Output(searchResults: list, scrollToTop: scroll, errorMessage: errorMessage)
    }
    
    private func fetch(keyword: String, handler: @escaping (SearchResults) -> Void, errorMessage: PublishRelay<String>) {
        do {
            let data = Search(keyword: keyword, page: page, sort: sort)
            let request = try URLRequestManager.search(query: data).asURLRequest()
            let result = UnsplashNetwork.shared.fetchSearchResultsSingle(of: SearchResults.self, request: request)
            Observable.just(result)
                .flatMap { $0 }
                .bind(with: self) { owner, results in
                    switch results {
                    case .success(let value):
                        handler(value)
                    case .failure(_): // 에러 받았을 때, 에러 메시지 보내기
                        errorMessage.accept("검색결과를 불러올 수 없습니다")
                    }
                }.disposed(by: disposeBag)
        } catch {
            print("error")
        }
    }
}
