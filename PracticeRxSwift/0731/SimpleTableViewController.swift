//
//  SimpleTableViewController.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 7/31/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class SimpleTableViewController: BaseViewController {
    // DisposeBag 클래스가 deinit 될 때, 리소스 정리됨
    private let disposeBag = DisposeBag()
    private let tableView = UITableView()
    
    override func setupHierarchy() {
        view.addSubview(tableView)
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func setupUI() {
        super.setupUI()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func bind() {
        // 0부터 19까지의 수를 String으로 전송
        let items = Observable.just((0..<20).map { "\($0)" })
        
        // == cellForRowAt
        // (Int, Element, Cell) -> Void
        items
            .bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { (row, element, cell) in
                cell.textLabel?.text = element
                cell.accessoryType = .detailDisclosureButton
            }.disposed(by: disposeBag)
        
        // == didSelectRowAt
        tableView.rx.modelSelected(String.self)
            .subscribe(with: self) { owner, value in
                owner.showAlert(title: "셀 탭", message: "\(value)번 행을 눌렀어요!")
            }.disposed(by: disposeBag)
        
        // 우측 detailDisclosureButton 눌렀을 때
        tableView.rx.itemAccessoryButtonTapped
            .subscribe(with: self) { owner, indexPath in
                let section = indexPath.section
                let row = indexPath.row
                owner.showAlert(title: "", message: "\(section)섹션 \(row)행을 눌렀어요!")
            }.disposed(by: disposeBag)
    }
}
