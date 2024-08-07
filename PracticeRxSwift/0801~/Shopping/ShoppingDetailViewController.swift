//
//  ShoppingDetailViewController.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 8/3/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ShoppingDetailViewController: BaseViewController {
    private let nameTextField = UITextField()
    private let border = UIView()
    private let infoLabel = UILabel()
    
    var sendItem: ((Observable<String>) -> Void)?
    var itemName = BehaviorRelay(value: "")
    private let disposeBag = DisposeBag()
 
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let itemName = nameTextField.text else { return }
        sendItem?(Observable.just(itemName))
    }
    
    override func setupHierarchy() {
        view.addSubview(nameTextField)
        view.addSubview(border)
        view.addSubview(infoLabel)
    }
    
    override func setupConstraints() {
        nameTextField.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        border.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(4)
            make.height.equalTo(1)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        infoLabel.snp.makeConstraints { make in
            make.top.equalTo(border.snp.bottom).offset(6)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
        }
    }
    
    override func setupUI() {
        super.setupUI()
        nameTextField.placeholder = "구매목록의 상품명을 적어주세요"
        infoLabel.text = "상품명은 1글자 이상 입력해주세요"
        border.backgroundColor = Color.gray5
    }
    
    override func bind() {
        // 받아온 상품명 세팅
        itemName
            .bind(to: nameTextField.rx.text)
            .disposed(by: disposeBag)
        
        // 수정중인 상품명에 글자가 하나도 없다면 infoLabel 보여주고 뒤로가기 불가능하게 처리
        nameTextField.rx.text.orEmpty
            .map { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .bind(with: self) { owner, value in
                owner.infoLabel.isHidden = value
                let color = value ? Color.black : Color.lightGray
                owner.navigationController?.navigationBar.tintColor = color
                owner.navigationController?.navigationBar.isUserInteractionEnabled = value
            }.disposed(by: disposeBag)
    }
}
