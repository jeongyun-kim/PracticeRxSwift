//
//  PasswordViewModel.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 8/5/24.
//

import Foundation
import RxSwift
import RxCocoa

final class PasswordViewModel {
    private let disposeBag = DisposeBag()
    
    private let validText = Observable.just("8자 이상 입력해주세요")
    
    struct Input {
        let nextButtonTapped: ControlEvent<Void>
        let password: ControlProperty<String> // 입력한 비밀번호
    }
    
    struct Output {
        let nextButtonTapped: ControlEvent<Void>
        let validText: Observable<String>
        let isValidPassword: Observable<Bool> // 비밀번호가 조건에 부합하는지
    }
    
    func transform(_ input: Input) -> Output {
        let validText = Observable.just("8자 이상 입력해주세요")
        let isValidPassword = input.password.map { $0.count >= 8 }
        
        let output = Output(nextButtonTapped: input.nextButtonTapped, validText: validText, isValidPassword: isValidPassword)
        return output
    }
}
