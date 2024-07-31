//
//  PickerViewController.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 7/30/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class PickerViewController: BaseViewController {
    private let disposeBag = DisposeBag()
    private let pickerView = UIPickerView()
    private let descLabel = UILabel()
    
    override func setupHierarchy() {
        view.addSubview(descLabel)
        view.addSubview(pickerView)
    }
    
    override func setupConstraints() {
        descLabel.snp.makeConstraints { make in
            make.height.equalTo(56)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(48)
            make.center.equalTo(view.safeAreaLayoutGuide)
        }
        
        pickerView.snp.makeConstraints { make in
            make.top.equalTo(descLabel.snp.bottom)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func setupUI() {
        super.setupUI()
        descLabel.backgroundColor = .systemGray6
        descLabel.textAlignment = .center
        descLabel.text = "카테고리를 선택해보세요"
    }
    
    override func bind() {
        // pickerView에 보여줄 타이틀 데이터
        let categories = ["영화", "애니메이션", "드라마", "예능", "다큐멘터리", "기타"]
        let items = Observable.just(categories) // 이 배열 전체를 보내겠다
        
        items // itemTitles가 (Int, Sequence.Element) -> String?
            .bind(to: pickerView.rx.itemTitles) { (row, element) in
                return element
            }.disposed(by: disposeBag)
        
        // pickerView 내 row가 선택될 때마다
        pickerView.rx.modelSelected(String.self)
            .map { $0.description }
            .bind(to: descLabel.rx.text) // descLabel의 text로 선택한 데이터의 description을 넣어줘
            .disposed(by: disposeBag)
        
//        pickerView.rx.modelSelected(String.self)
//            .map { $0.description }
//            .bind(with: self) { owner, category in
//                owner.descLabel.text = category
//            }.disposed(by: disposeBag)
    }
}
