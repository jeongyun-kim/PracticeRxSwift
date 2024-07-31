//
//  SubjectViewController.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 7/31/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class SubjectViewController: BaseViewController {
    private let disposeBag = DisposeBag()
    //MARK: Subject
    // - Observable이면서 동시에 Observer로 쓰고싶을 때 사용
    // - Publish, Behavior이 90% 이상 사용됨
    // Publish: 초깃값이 필요없음 / Behavior: 초깃값이 필요함
    // 🧐 Combine의 Passthrough / CurrentValue인듯
    
    // Publish 사용 시, 제네릭으로 타입 표시해줄 것
    private let intValue = PublishSubject<Int>()
    private let strValue = PublishSubject<String>()
    // BehaviorSubject는 초깃값을 가지고 시작
    private let behaviorInt = BehaviorSubject(value: 1)
    private let behaviorStr = BehaviorSubject(value: "A")
    
    override func bind() {
        Observable.combineLatest(intValue, strValue) { element1, element2 in
            return "Publish: \(element1) + \(element2)"
        }.subscribe(with: self) { owner, value in
            print(value)
        }.disposed(by: disposeBag)
        //.dispose() // 이벤트 처리할 준비할 새도 없이 고냥 스탑
        
        // 이 상황에서는 아무런 print도 찍히지 않음
        // 왜? => combineLatest는 각 이벤트가 한 번씩은 방출되어야하니까
        
        // 이 때에도 print문은 실행되지 않음
        // strValue 이벤트를 방출하지 않았기 때문
        intValue.onNext(10)
        // 이 때부터 print문 실행
        strValue.onNext("123")
        // 결과: 10 + 123
        intValue.onNext(11)
        // 결과: 11 + 123
        
        // ========================================
        
        Observable.combineLatest(behaviorInt, behaviorStr) { element1, element2 in
            return "Behavior: \(element1) + \(element2)"
        }.subscribe { value in
            print(value)
        }.disposed(by: disposeBag)
        // 결과: next(Behavior: 1 + A)
        // - BehaviorSubject는 초깃값을 가지고 최신 이벤트를 받아오면 새로운 이벤트 처리 
        
        behaviorInt.onNext(9)
        // 결과: next(Behavior: 9 + A)
        
        
        // ========================================
        
        // 둘은 어떨 때 사용될까
        // - Publish는 초깃값이 필요없으니까 리캡의 검색화면 내 데이터 같은거 아닐까
        // - Behavior는 초깃값이 있으니까 좋아요 화면이나 프로필 편집뷰..?
    }
}
