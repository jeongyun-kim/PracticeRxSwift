//
//  AddNumberViewController.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 7/31/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class AddNumberViewController: BaseViewController {
    private let disposeBag = DisposeBag()
    private let number1 = UITextField()
    private let number2 = UITextField()
    private let number3 = UITextField()
    private let resultLabel = UILabel()
    
    override func setupHierarchy() {
        view.addSubview(number1)
        view.addSubview(number2)
        view.addSubview(number3)
        view.addSubview(resultLabel)
    }
    
    override func setupConstraints() {
        number1.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(15)
            make.height.equalTo(56)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(50)
        }
        
        number2.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(15)
            make.height.equalTo(56)
            make.top.equalTo(number1.snp.bottom).offset(12)
        }
        
        number3.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(15)
            make.height.equalTo(56)
            make.top.equalTo(number2.snp.bottom).offset(12)
        }
        
        resultLabel.snp.makeConstraints { make in
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.top.equalTo(number3.snp.bottom).offset(12)
        }
    }
    
    override func setupUI() {
        super.setupUI()
        [number1, number2, number3].forEach { textField in
            textField.backgroundColor = .systemGray6
        }
    }
    
    override func bind() {
        // 세 텍스트필드 내 숫자 더해서 보여주기 
        Observable
        // MARK: CombineLatest
        // - 여러 Observable 중 하나의 Observable에만 이벤트가 방출되더라도 다같이 묶여있는 Observable에 이벤트가 방출됨
        // ⚠️ 각 항목이 모두 최소 한 번씩은 방출되어야함 
        // (O1.Element, O2.Element, O3.Element) -> Int
            .combineLatest(number1.rx.text.orEmpty, number2.rx.text.orEmpty, number3.rx.text.orEmpty) { element1, element2, element3 in
                let num1 = Int(element1) ?? 0
                let num2 = Int(element2) ?? 0
                let num3 = Int(element3) ?? 0
            return num1+num2+num3
        }
            .map { $0.description }
            .bind(to: resultLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
