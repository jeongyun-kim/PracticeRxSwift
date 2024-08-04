//
//  ShoppingSearchViewController.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 8/3/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ShoppingSearchViewController: BaseViewController {
    private enum Update {
        case complete
        case bookmark
        case remove
        case rename(newName: String)
    }
    
    private let tableView = UITableView()
    private let searchController = UISearchController()
    
    var list: [Item] = []
    private lazy var items = BehaviorRelay(value: list)
    private let disposeBag = DisposeBag()
    var sendList: (([Item]) -> Void)?
    
    // 뒤로가기할 때 변경된 데이터 보내주기
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sendList?(list)
    }
    
    override func setupHierarchy() {
        view.addSubview(tableView)
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view)
        }
    }
    
    override func setupUI() {
        super.setupUI()
        configureSearchController()
        
        navigationItem.title = "검색"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        tableView.register(ShoppingTableViewCell.self, forCellReuseIdentifier: ShoppingTableViewCell.identifier)
        tableView.rowHeight = 70
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
    }
    
    private func configureSearchController() {
        searchController.searchBar.placeholder = "무엇을 찾으실래요?"
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.automaticallyShowsCancelButton = false
    }
    
    // MARK: bind
    override func bind() {
        // 테이블뷰 셀 그리기
        items
            .bind(to: tableView.rx.items(cellIdentifier: ShoppingTableViewCell.identifier,
                                         cellType: ShoppingTableViewCell.self)) { (row, element, cell) in
            cell.configureCell(element)
            // - 완료 버튼 눌렀을 때
            cell.completeButton.rx.tap
                .bind(with: self) { owner, _ in
                    owner.updateItems(row, updateType: .complete)
                    owner.updateOriginalData(row, updateType: .complete)
                }.disposed(by: cell.disposeBag)
            // - 즐겨찾기 버튼 눌렀을 때
            cell.bookmarkButton.rx.tap
                .bind(with: self) { owner, _ in
                    owner.updateItems(row, updateType: .bookmark)
                    owner.updateOriginalData(row, updateType: .bookmark)
                }.disposed(by: cell.disposeBag)
        }.disposed(by: disposeBag)
        
        // 테이블뷰 셀 선택 시 상세정보뷰 불러오기
        Observable
            .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(Item.self))
            .subscribe(with: self) { owner, value in
                // - 상세정보뷰로 현재 선택한 상품명 보내기
                let itemName = value.1.name
                let vc = ShoppingDetailViewController()
                vc.itemName.accept(itemName)
                
                // - 상세정보에서 상품명을 수정했다면 수정한 이름으로 데이터 재구성
                vc.sendItem = { newItemName in
                    let row = value.0.row
                    owner.updateOriginalData(row, updateType: .rename(newName: newItemName))
                    owner.updateItems(row, updateType: .rename(newName: newItemName))
                }
                owner.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: disposeBag)
        
        // 우측에서 좌측으로 스와이프 -> 아이템 삭제
        tableView.rx.itemDeleted
            .bind(with: self) { owner, indexPath in
                let row = indexPath.row
                owner.updateOriginalData(row, updateType: .remove)
                owner.updateItems(row, updateType: .remove)
            }.disposed(by: disposeBag)
        
        // 실시간 검색
        searchController.searchBar.rx.text.orEmpty
            .bind(with: self) { owner, keyword in
                owner.setItems(keyword)
            }.disposed(by: disposeBag)
    }
    
    // MARK: 데이터 처리
    // 현재 키워드에 따라 보여지는 데이터 리스트 다르게
    private func setItems(_ keyword: String) {
        if keyword.isEmpty {
            items.accept(list)
        } else {
            let filteredList = list.filter { $0.name.contains(keyword) }
            items.accept(filteredList)
        }
    }
    
    // 현재 업데이트를 할 데이터가 찐데이터들중에서 몇 번째에 있는지
    private func getItemIdxFromList(_ row: Int) -> Int? {
        let data = items.value[row]
        guard let itemIdx = list.firstIndex(where: { $0.name == data.name }) else { return nil }
        return itemIdx
    }
    
    // 찐리스트 업데이트
    private func updateOriginalData(_ row: Int, updateType: Update) {
        guard let idx = getItemIdxFromList(row) else { return }

        switch updateType {
        case .complete:
            list[idx].isComplete.toggle()
        case .bookmark:
            list[idx].bookmark.toggle()
        case .remove:
            list.remove(at: idx)
        case .rename(let newName):
            list[idx].name = newName
        }
    }
    
    // 보여지고 있는 데이터 리스트 업데이트
    private func updateItems(_ row: Int, updateType: Update) {
        // 현재 보여지고 있는 데이터 리스트
        var currentItems = items.value
        
        switch updateType {
        case .complete:
            currentItems[row].isComplete.toggle()
        case .bookmark:
            currentItems[row].bookmark.toggle()
        case .remove:
            currentItems.remove(at: row)
        case .rename(let newName):
            currentItems[row].name = newName
        }
        // 보여지는 데이터 리스트 업데이트
        items.accept(currentItems)
    }
}
