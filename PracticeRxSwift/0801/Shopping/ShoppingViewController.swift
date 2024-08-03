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
        navigationItem.title = "쇼핑"
        contentView.backgroundColor = Color.gray6
        contentView.layer.cornerRadius = 8
        itemTextField.backgroundColor = Color.gray6
        itemTextField.placeholder = "무엇을 구매하실 건가요?"
        addButton.setTitle("추가", for: .normal)
        addButton.tintColor = Color.gray5
        addButton.setTitleColor(Color.black, for: .normal)
        tableView.register(ShoppingTableViewCell.self, forCellReuseIdentifier: ShoppingTableViewCell.identifier)
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
    }
    
    override func bind() {
        items.bind(to: tableView.rx.items(cellIdentifier: ShoppingTableViewCell.identifier, cellType: ShoppingTableViewCell.self)) { (row, element, cell) in
            cell.configureCell(element)
        }.disposed(by: disposeBag)
    }
}
