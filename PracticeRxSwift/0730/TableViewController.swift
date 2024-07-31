//
//  TableViewController.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 7/30/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class TableViewController: BaseViewController {
    private let tableView = UITableView()
    private let resultLabel = UILabel()
    private let disposeBag = DisposeBag()
    
    override func setupHierarchy() {
        view.addSubview(tableView)
        view.addSubview(resultLabel)
    }
    
    override func setupConstraints() {
        resultLabel.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(resultLabel.snp.bottom)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func setupUI() {
        super.setupUI()
        resultLabel.backgroundColor = .systemGray6
    }
    
    override func bind() {
        // 시스템 셀 추가
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        let data = [0, 1, 2, 3, 4]
        let items = Observable.just(data)
        
        // == cellForRowAt
        // items: (UITableView, Int, Sequence.Element) -> UITableViewCell
        items.bind(to: tableView.rx.items) { (tableView, row, element) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = "\(element) @ row \(row)"
            return cell
        }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Int.self)
            .map { data in
                "\(data)를 클릭했어요!"
            }
            .bind(to: resultLabel.rx.text) // resultLabel에 텍스트 꽂아넣기
            .disposed(by: disposeBag)
    }
}
