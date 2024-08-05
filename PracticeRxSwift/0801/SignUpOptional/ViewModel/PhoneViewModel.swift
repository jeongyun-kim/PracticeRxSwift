//
//  PhoneViewModel.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 8/5/24.
//

import Foundation
import RxSwift
import RxCocoa

final class PhoneViewModel {
    private let disposeBag = DisposeBag()
    
    struct Input {
        let nextButtonTapped: ControlEvent<Void>
        let phoneNumber: ControlProperty<String>
    }
    
    struct Output {
        let nextButtonTapped: ControlEvent<Void>
        let defaultPhoneNumber: BehaviorRelay<String>
        let isValidPhoneNumber: Observable<Bool>
    }
    
    func transform(_ input: Input) -> Output {
        let defaultNumber = BehaviorRelay(value: "010")
        let isValidPhoneNumber = input.phoneNumber.map { $0.count >= 10 && Int($0) != nil }

        let output = Output(nextButtonTapped: input.nextButtonTapped, defaultPhoneNumber: defaultNumber, isValidPhoneNumber: isValidPhoneNumber)
        return output
    }
}
