//
//  SignUpViewModel.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 8/5/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SignUpViewModel {
    private let disposeBag = DisposeBag()
    
    struct Input {
        let nextButtonTapped: ControlEvent<Void>
        let email: ControlProperty<String> // 이메일 입력될때마다 받아오기 
    }
    
    struct Output {
        let nextButtonTapped: ControlEvent<Void>
        let isValidEmail: Observable<Bool> // 이메일이 유효한지
    }
    
    func transform(_ input: Input) -> Output {
        // 유효한 이메일인지 확인
        let isValid = input.email.map { self.validateEmail($0) }
        let output = Output(nextButtonTapped: input.nextButtonTapped, isValidEmail: isValid)
        return output
    }
    
    private func validateEmail(_ email: String) -> Bool {
        // 이메일 입력칸 유효성 확인
        // - [A-Z0-9a-z._%+-]: 대소문자, 숫자, 특수문자 사용 가능
        // - +@: []과 []사이에 @가 필수로 들어가게
        // - [A-Za-z0-9.-]: 대소문자, 숫자 사용 가능
        // - +\\.: []과 []사이에 .가 필수로 들어가게
        // -[A-Za-z]: 대소문자 사용 가능
        // - {2,6}: 앞의 [A-Za-z]를 2~6자리로 제한
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let result = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
        return result
    }
}
