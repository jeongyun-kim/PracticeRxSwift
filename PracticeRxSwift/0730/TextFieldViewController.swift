//
//  TextFieldViewController.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 7/30/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class TextFieldViewController: BaseViewController {
    private let emailTextField = UITextField()
    private let nameTextField = UITextField()
    private let resultLabel = UILabel()
    private let signButton = UIButton()
    private let disposeBag = DisposeBag()
    
    override func setupHierarchy() {
        view.addSubview(nameTextField)
        view.addSubview(emailTextField)
        view.addSubview(resultLabel)
        view.addSubview(signButton)
    }
    
    override func setupConstraints() {
        nameTextField.snp.makeConstraints { make in
            make.height.equalTo(56)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.height.equalTo(56)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.top.equalTo(nameTextField.snp.bottom).offset(12)
        }
        
        resultLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.top.equalTo(emailTextField.snp.bottom).offset(12)
        }
        
        signButton.snp.makeConstraints { make in
            make.size.equalTo(55)
            make.centerX.equalTo(nameTextField.snp.centerX)
            make.top.equalTo(resultLabel.snp.bottom).offset(12)
        }
    }
    
    override func setupUI() {
        super.setupUI()
        nameTextField.backgroundColor = .systemGray6
        nameTextField.placeholder = "이름을 입력하세요"
        emailTextField.backgroundColor = .systemGray6
        emailTextField.placeholder = "이메일을 입력하세요"
        resultLabel.numberOfLines = 0
        signButton.backgroundColor = .systemYellow
        signButton.setTitle("완료", for: .normal)
    }
    
    override func bind() {
        // source1, 2 묶어서 처리
        // - orEmpty : textField.text = String?을 String으로 반환
        Observable.combineLatest(emailTextField.rx.text.orEmpty, nameTextField.rx.text.orEmpty) { email, name in
                return "name은 \(name)이고 email은 \(email)입니다!"
        }
        .bind(to: resultLabel.rx.text)
        .disposed(by: disposeBag)
        
        // 이름이 2글자 미만이라면 이메일 텍스트 필드랑 가입 버튼 숨기기
        nameTextField.rx.text.orEmpty
            .map { $0.count < 2 }
            .bind(to: emailTextField.rx.isHidden, signButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        // 이메일이 4글자 이상이라면 가입 버튼 enable
        emailTextField.rx.text.orEmpty
            .map { $0.count >= 4 }
            .bind(to: signButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // 가입 버튼을 누르면 Alert 띄우기
        signButton.rx.tap
            .subscribe(with: self) { owner, _ in
                print(#function)
                owner.showAlert()
            }.disposed(by: disposeBag)
    }
}
