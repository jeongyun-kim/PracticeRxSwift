//
//  SwitchViewController.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 7/30/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class SwitchViewController: BaseViewController {
    private let `switch` = UISwitch()
    private let disposeBag = DisposeBag()
    
    override func setupHierarchy() {
        view.addSubview(`switch`)
    }
    
    override func setupConstraints() {
        `switch`.snp.makeConstraints { make in
            make.size.equalTo(60)
            make.center.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func setupUI() {
        super.setupUI()
    }
    
    override func bind() {
        // 새로운 Observable 인스턴스 생성
        Observable.of(false)
            .bind(to: `switch`.rx.isOn)
            .disposed(by: disposeBag)
    }
}
