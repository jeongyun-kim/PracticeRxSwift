//
//  ValidationViewController.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 7/31/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class ValidationViewController: BaseViewController {
    private let disposeBag = DisposeBag()
    private let userNameTextField = UITextField()
    private let validNameLabel = UILabel()
    private let pwTextField = UITextField()
    private let validPwLabel = UILabel()
    private let validateButton = UIButton()
    
    override func setupHierarchy() {
        view.addSubview(userNameTextField)
        view.addSubview(validNameLabel)
        view.addSubview(pwTextField)
        view.addSubview(validPwLabel)
        view.addSubview(validateButton)
    }
    
    override func setupConstraints() {
        userNameTextField.snp.makeConstraints { make in
            make.height.equalTo(56)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
        }
        
        validNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(userNameTextField.snp.leading)
            make.top.equalTo(userNameTextField.snp.bottom).offset(4)
        }
        
        pwTextField.snp.makeConstraints { make in
            make.height.equalTo(56)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.top.equalTo(validNameLabel.snp.bottom).offset(12)
        }
        
        validPwLabel.snp.makeConstraints { make in
            make.leading.equalTo(pwTextField.snp.leading)
            make.top.equalTo(pwTextField.snp.bottom).offset(4)
        }
        
        validateButton.snp.makeConstraints { make in
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(validPwLabel.snp.bottom).offset(12)
        }
    }
    
    override func setupUI() {
        super.setupUI()
        [userNameTextField, pwTextField].forEach { textField in
            textField.backgroundColor = .systemGray6
        }
        validNameLabel.text = "닉네임은 4글자 이상으로 입력해주세요"
        validPwLabel.text = "비밀번호는 6글자 이상으로 입력해주세요"
        pwTextField.isSecureTextEntry = true
        validateButton.setTitle("가입하기", for: .normal)
        validateButton.backgroundColor = .systemYellow
    }
    
    override func bind() {
        let userNameValid = userNameTextField.rx.text.orEmpty
            .map { $0.count >= 4 }
            .share(replay: 1)
    
        //MARK: Share(1)
        // - 일반적으로 subscribe(bind)마다 새로운 시퀀스가 생성됨
        // = 하나의 Observable을 subscribe하는 곳이 여러 군데라면 그만큼 호출되면서 스트림이 생겨나 불필요한 리소스 발생 가능
        // share를 통해 이를 해결 가능
        // - replay: 신규 subscriber에게 이전 방출했던 값을 요소가 몇 개인지 기록했다가 방출할(replay) 것인지 
        let passwordValid = pwTextField.rx.text.orEmpty
            .map { $0.count >= 6 }
            .share(replay: 1)
        
        // 닉네임이랑 비밀번호의 조건이 모두 만족할 때
        let validation = Observable.combineLatest(userNameValid, passwordValid) { $0 && $1 }
            .share(replay: 1)
        
        userNameValid
            .bind(to: pwTextField.rx.isEnabled, validNameLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        passwordValid
            .bind(to: validPwLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        validation
            .bind(to: validateButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        validateButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.showAlert()
            }.disposed(by: disposeBag)
    }
}
