//
//  PasswordViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class PasswordViewController: BaseViewController {
    let passwordTextField = SignTextField(placeholderText: "비밀번호를 입력해주세요")
    let nextButton = PointButton(title: "다음")
    
    private let disposeBag = DisposeBag()
    private let validLabel = UILabel()
    private let validText = Observable.just("8자 이상 입력해주세요")
    
    override func setupHierarchy() {
        view.addSubview(passwordTextField)
        view.addSubview(validLabel)
        view.addSubview(nextButton)
    }
    
    override func setupConstraints() {
        passwordTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        validLabel.snp.makeConstraints { make in
            make.leading.equalTo(passwordTextField.snp.leading)
            make.top.equalTo(passwordTextField.snp.bottom).offset(4)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(passwordTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    override func setupUI() {
        super.setupUI()
        passwordTextField.isSecureTextEntry = true
    }
    
    override func bind() {
        // 다음 버튼 눌렀을 때 PhoneVC로
        nextButton.rx.tap
            .bind(with: self) { owner, _ in
                let vc = PhoneViewController()
                owner.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: disposeBag)
        
        // '8자 이상 입력해주세요' 세팅
        validText
            .bind(to: validLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 입력한 비밀번확 8자 이상인지 확인 후 처리
        // - validLabel 숨기기
        // - 컬러 변경하기
        passwordTextField.rx.text.orEmpty
            .map { $0.count >= 8 }
            .bind(with: self) { owner, isValid in
                let color: UIColor = isValid ? .systemGreen : .lightGray
                owner.nextButton.backgroundColor = color
                owner.nextButton.isEnabled = isValid
                owner.validLabel.isHidden = isValid
            }.disposed(by: disposeBag)
    }
}
