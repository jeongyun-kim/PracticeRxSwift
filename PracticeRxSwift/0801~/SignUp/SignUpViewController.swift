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
    private let vm = SignUpViewModel()

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
        // input 생성해서 보내고
        let input = SignUpViewModel.Input(nextButtonTapped: nextButton.rx.tap, email: emailTextField.rx.text.orEmpty)
        // output 받아오기
        let output = vm.transform(input)
        
        // 다음 버튼 눌렀을 때 화면전환
        output.nextButtonTapped
            .bind(with: self) { owner, _ in
                owner.navigationController?.pushViewController(PasswordViewController(), animated: true)
            }.disposed(by: disposeBag)
        
        // 유효한 이메일인지 확인하고 UI 변경
        output.isValidEmail
            .bind(with: self, onNext: { owner, isValid in
                let color: UIColor = isValid ? .systemGreen : .lightGray
                owner.nextButton.backgroundColor = color
                owner.nextButton.isEnabled = isValid
            })
            .disposed(by: disposeBag)
    }
}
