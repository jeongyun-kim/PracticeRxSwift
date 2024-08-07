//
//  NicknameViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class NicknameViewController: BaseViewController {
    private let nicknameTextField = SignTextField(placeholderText: "닉네임을 입력해주세요")
    private let nextButton = PointButton(title: "다음")
    
    private let disposeBag = DisposeBag()
    private let vm = NicknameViewModel()

    override func setupHierarchy() {
        view.addSubview(nicknameTextField)
        view.addSubview(nextButton)
    }
    
    override func setupConstraints() {
        nicknameTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(nicknameTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    override func setupUI() {
        super.setupUI()
    }
    
    override func bind() {
        let input = NicknameViewModel.Input(nextButtonTapped: nextButton.rx.tap, nickname: nicknameTextField.rx.text.orEmpty)
        let output = vm.transform(input)
        
        // 다음 버튼 누르면 생일뷰로
        output.nextButtonTapped
            .bind(with: self) { owner, _ in
                owner.navigationController?.pushViewController(BirthdayViewController(), animated: true)
            }.disposed(by: disposeBag)
        
        // 닉네임이 2글자 이상 8글자 이하라면
        output.isValidNickname
            .bind(with: self) { owner, isValid in
                let color: UIColor = isValid ? .systemGreen : .lightGray
                owner.nextButton.isEnabled = isValid
                owner.nextButton.backgroundColor = color
            }.disposed(by: disposeBag)
    }
}
