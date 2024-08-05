//
//  NicknameViewModel.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 8/5/24.
//

import UIKit
import RxSwift
import RxCocoa

final class NicknameViewModel {
    private let disposeBag = DisposeBag()
    
    struct Input {
        let nextButtonTapped: ControlEvent<Void>
        let nickname: ControlProperty<String>
    }
    
    struct Output {
        let nextButtonTapped: ControlEvent<Void>
        let isValidNickname: Observable<Bool>
    }
    
    func transform(_ input: Input) -> Output {
        let isValid = input.nickname.map { 2 <= $0.count && $0.count <= 8 }
        
        let output = Output(nextButtonTapped: input.nextButtonTapped, isValidNickname: isValid)
        return output
    }
}
