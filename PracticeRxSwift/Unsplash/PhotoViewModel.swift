//
//  PhotoViewModel.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 8/11/24.
//

import Foundation
import RxSwift
import RxCocoa

final class PhotoViewModel {
    private let disposeBag = DisposeBag()
    
    struct Input {
        let searchBtnTapped: Observable<ControlProperty<String>.Element>
        let prefetchIdxs: ControlEvent<[IndexPath]>
    }
    
    struct Output {
        let searchResults: BehaviorRelay<[ReceivedPhoto]>
        let scrollToTop: PublishRelay<Void>
    }
    
    private var keyword = ""
    private var page = 1
    private let sort = "relevant"
    private var totalPages = 0
    
    func transform(_ input: Input) -> Output {
        let list: BehaviorRelay<[ReceivedPhoto]> = BehaviorRelay(value: [])
        let scroll = PublishRelay<Void>()
        
        input.searchBtnTapped
            .map { $0.lowercased() }
            .distinctUntilChanged()
            .throttle(.seconds(5), scheduler: MainScheduler.instance)
            .subscribe(with: self) { owner, keyword in
                owner.page = 1
                let search = Search(keyword: keyword, page: owner.page, sort: owner.sort)
                do {
                    let request = try URLRequestManager.search(query: search).asURLRequest()
                    let result = UnsplashNetwork.shared.fetchSearchResults(of: SearchResults.self, request: request)
                    result
                        .compactMap { $0 }
                        .bind(with: self) { owner, value in
                            owner.keyword = keyword
                            owner.totalPages = value.totalPages
                            list.accept(value.results)
                            scroll.accept(())
                        }.disposed(by: owner.disposeBag)
                } catch {
                    print("fetch error!")
                }
                
            } onError: { owner, error in
                print(error)
            } onCompleted: { _ in
                print("completed!")
            } onDisposed: { _ in
                print("disposed!")
            }.disposed(by: disposeBag)
        
        input.prefetchIdxs
            .compactMap { $0.last }
            .map { $0.row == list.value.count - 3 && self.page < self.totalPages }
            .filter { $0 }
            .bind(with: self) { owner, value in
                owner.page += 1
                let search = Search(keyword: owner.keyword, page: owner.page, sort: owner.sort)
                do {
                    let request = try URLRequestManager.search(query: search).asURLRequest()
                    let result = UnsplashNetwork.shared.fetchSearchResults(of: SearchResults.self, request: request)
                    result
                        .compactMap { $0 }
                        .bind(with: self) { owner, value in
                            // print(owner.keyword, owner.page, owner.sort, value)
                            var currentList = list.value
                            currentList.append(contentsOf: value.results)
                            list.accept(currentList)
                        }.disposed(by: owner.disposeBag)
                } catch {
                    print("fetch error!")
                }
            }.disposed(by: disposeBag)
        
        
        return Output(searchResults: list, scrollToTop: scroll)
    }
}
