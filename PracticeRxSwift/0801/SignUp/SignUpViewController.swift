//
//  SignUpViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SignUpViewController: BaseViewController {

    let emailTextField = SignTextField(placeholderText: "이메일을 입력해주세요")
    let validationButton = UIButton()
    let nextButton = PointButton(title: "다음")
    
    private let disposeBag = DisposeBag()
    private let bgColor = BehaviorRelay(value: UIColor.lightGray)

    override func setupHierarchy() {
        view.addSubview(emailTextField)
        view.addSubview(validationButton)
        view.addSubview(nextButton)
    }
    
    override func setupConstraints() {
        validationButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.width.equalTo(100)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.trailing.equalTo(validationButton.snp.leading).offset(-8)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(emailTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    override func setupUI() {
        super.setupUI()
        validationButton.setTitle("중복확인", for: .normal)
        validationButton.setTitleColor(Color.black, for: .normal)
        validationButton.layer.borderWidth = 1
        validationButton.layer.borderColor = Color.black.cgColor
        validationButton.layer.cornerRadius = 10
    }
    
    override func bind() {
        // 다음 버튼 눌렀을 때 화면전환
        nextButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.navigationController?.pushViewController(PasswordViewController(), animated: true)
            }.disposed(by: disposeBag)
        
        // bgColor 변경될 때마다 nextButton 색상 변경
        // - 초기값은 lightGray
        bgColor
            .bind(to: nextButton.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        // 이메일 입력칸 유효성 확인
        // - [A-Z0-9a-z._%+-]: 대소문자, 숫자, 특수문자 사용 가능
        // - +@: []과 []사이에 @가 필수로 들어가게
        // - [A-Za-z0-9.-]: 대소문자, 숫자 사용 가능
        // - +\\.: []과 []사이에 .가 필수로 들어가게
        // -[A-Za-z]: 대소문자 사용 가능
        // - {2,6}: 앞의 [A-Za-z]를 2~6자리로 제한
        emailTextField.rx.text.orEmpty
            .map {
                let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
                return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: $0)
            }
            .bind(with: self, onNext: { owner, isValid in
                let color: UIColor = isValid ? .systemGreen : .lightGray
                owner.bgColor.accept(color)
                owner.nextButton.isEnabled = isValid
            })
            .disposed(by: disposeBag)
    }
}
