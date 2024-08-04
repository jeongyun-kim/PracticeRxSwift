//
//  ShoppingViewController.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 8/3/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ShoppingViewController: BaseViewController {
    private let contentView = UIView()
    private let itemTextField = UITextField()
    private let addButton = UIButton(configuration: .filled())
    private let tableView = UITableView()
    
    private let disposeBag = DisposeBag()
    private var list = ItemList().list
    private var items = BehaviorRelay(value: ItemList().list)
    
    override func setupHierarchy() {
        view.addSubview(contentView)
        contentView.addSubview(itemTextField)
        contentView.addSubview(addButton)
        view.addSubview(tableView)
    }
    
    override func setupConstraints() {
        contentView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(56)
        }
       
        itemTextField.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.centerY.equalTo(contentView.snp.centerY)
            make.leading.equalTo(contentView.snp.leading).offset(12)
        }
        
        addButton.snp.makeConstraints { make in
            make.centerY.equalTo(contentView.snp.centerY)
            make.trailing.equalTo(contentView.snp.trailing).inset(12)
            make.leading.greaterThanOrEqualTo(itemTextField.snp.trailing).offset(12)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.bottom).offset(16)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func setupUI() {
        super.setupUI()
        configureNavigation()
        
        contentView.backgroundColor = Color.gray6
        contentView.layer.cornerRadius = 8
        
        itemTextField.backgroundColor = Color.gray6
        itemTextField.placeholder = "무엇을 구매하실 건가요?"
        
        addButton.setTitle("추가", for: .normal)
        addButton.tintColor = Color.gray5
        addButton.setTitleColor(Color.black, for: .normal)
        
        tableView.register(ShoppingTableViewCell.self, forCellReuseIdentifier: ShoppingTableViewCell.identifier)
        tableView.rowHeight = 70
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
    }
    
    override func bind() {
        // 테이블뷰 셀 그리기
        items.bind(to: tableView.rx.items(cellIdentifier: ShoppingTableViewCell.identifier, cellType: ShoppingTableViewCell.self)) { (row, element, cell) in
            cell.configureCell(element)
            // 완료 버튼 눌렀을 때
            cell.completeButton.rx.tap
                .bind(with: self) { owner, _ in
                    owner.list[row].isComplete.toggle()
                    owner.items.accept(owner.list)
                }.disposed(by: cell.disposeBag)
            // 즐겨찾기 버튼 눌렀을 때
            cell.bookmarkButton.rx.tap
                .bind(with: self) { owner, _ in
                    owner.list[row].bookmark.toggle()
                    owner.items.accept(owner.list)
                }.disposed(by: cell.disposeBag)
        }.disposed(by: disposeBag)
        
        // 테이블뷰 셀 선택 시 상세정보뷰 불러오기
        // - 상세정보로 현재 상품명 보내주기 
        // - 상세정보에서 상품명 수정하고 돌아오면 리스트 업데이트
        Observable
            .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(Item.self))
            .subscribe(with: self) { owner, value in
                // 상세정보뷰로 현재 선택한 상품명 보내기
                let itemName = value.1.name
                let vc = ShoppingDetailViewController()
                vc.itemName.accept(itemName)
                // 상세정보에서 상품명을 수정했다면 수정한 이름으로 데이터 재구성
                vc.sendItem = { newItemName in
                    owner.list[value.0.row].name = newItemName
                    owner.items.accept(owner.list)
                }
                owner.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: disposeBag)
        
        // 우측에서 좌측으로 스와이프 -> 아이템 삭제 
        tableView.rx.itemDeleted
            .bind(with: self) { owner, indexPath in
                owner.list.remove(at: indexPath.row)
                owner.items.accept(owner.list)
            }.disposed(by: disposeBag)
        
        // 추가버튼 눌렀을 때 아이템 추가
        addButton.rx.tap
            .withLatestFrom(itemTextField.rx.text.orEmpty)
            .bind(with: self) { owner, itemName in
                guard !itemName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                let item = Item(name: itemName)
                owner.list.insert(item, at: 0)
                owner.items.accept(owner.list)
                owner.itemTextField.text = ""
            }.disposed(by: disposeBag)
    }
    
    private func configureNavigation() {
        navigationItem.title = "쇼핑"
        let search = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(searchBtnTapped))
        navigationItem.rightBarButtonItem = search
    }
    
    @objc private func searchBtnTapped(_ sender: UIButton) {
        let vc = ShoppingSearchViewController()
        vc.list = list
        vc.sendList = { [weak self] list in
            guard let self else { return }
            self.list = list
            self.items.accept(list)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}
