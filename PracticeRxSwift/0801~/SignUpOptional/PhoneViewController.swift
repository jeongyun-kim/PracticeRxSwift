//
//  PhoneViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//
 
import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class PhoneViewController: BaseViewController {
    private let phoneTextField = SignTextField(placeholderText: "연락처를 입력해주세요")
    private let nextButton = PointButton(title: "다음")
    
    private let disposeBag = DisposeBag()
    private let vm = PhoneViewModel()
    
    override func setupHierarchy() {
        view.addSubview(phoneTextField)
        view.addSubview(nextButton)
    }
    
    override func setupConstraints() {
        phoneTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(phoneTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    override func setupUI() {
        super.setupUI()
    }
    
    override func bind() {
        let input = PhoneViewModel.Input(nextButtonTapped: nextButton.rx.tap, phoneNumber: phoneTextField.rx.text.orEmpty)
        let output = vm.transform(input)
        
        // 다음 버튼 눌렀을 때 화면전환
        output.nextButtonTapped
            .bind(with: self) { owner, _ in
                let vc = NicknameViewController()
                owner.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: disposeBag)
        
        // phoneTextField에 010 세팅
        output.defaultPhoneNumber
            .bind(to: phoneTextField.rx.text)
            .disposed(by: disposeBag)
            
        // 전화번호 유효성 확인
        // - 전화번호 길이가 10자 이상일 때
        // - 숫자만 입력했을 때
        output.isValidPhoneNumber
            .bind(with: self) { owner, isValid in
                let color: UIColor = isValid ? .systemGreen : .lightGray
                owner.nextButton.backgroundColor = color
                owner.nextButton.isEnabled = isValid
            }.disposed(by: disposeBag)
    }
}
