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
    private let tableView = UITableView()
    private let searchController = UISearchController()
    
    let vm = ShoppingSearchViewModel()
    private let disposeBag = DisposeBag()
    var sendList: (([Item]) -> Void)?
    
    // 뒤로가기할 때 변경된 데이터 보내주기
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sendList?(vm.list.value)
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
        let searchKeyword = searchController.searchBar.rx.text.orEmpty
        let completeItem = PublishRelay<Int>()
        let bookmarkItem = PublishRelay<Int>()
        let renameItem = PublishRelay<(Int, String)>()
        let removeItem = tableView.rx.itemDeleted
        let selectedItem = Observable
            .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(Item.self))
        
        let input = ShoppingSearchViewModel.Input(searchKeyword: searchKeyword, completeItem: completeItem, 
                                                  bookmarkItem: bookmarkItem, renameItem: renameItem,
                                                  removeItem: removeItem, selectedItem: selectedItem)
        let output = vm.transform(input)
        
        // 테이블뷰 셀 그리기
        output.items
            .bind(to: tableView.rx.items(cellIdentifier: ShoppingTableViewCell.identifier,
                                         cellType: ShoppingTableViewCell.self)) { (row, element, cell) in
            cell.configureCell(element)
            // - 완료 버튼 눌렀을 때
            cell.completeButton.rx.tap
                    .map { row }
                    .bind(to: completeItem)
                    .disposed(by: cell.disposeBag)
            // - 즐겨찾기 버튼 눌렀을 때
            cell.bookmarkButton.rx.tap
                    .map { row }
                    .bind(to: bookmarkItem)
                    .disposed(by: cell.disposeBag)
        }.disposed(by: disposeBag)
        
        // 테이블뷰 셀 선택 시 상세정보뷰 불러오기
        output.selectedItem
            .subscribe(with: self) { owner, value in
                // - 상세정보뷰로 현재 선택한 상품명 보내기
                let itemName = value.1.name
                let vc = ShoppingDetailViewController()
                vc.itemName.accept(itemName)
                // - 상세정보에서 상품명을 수정했다면 수정한 이름으로 데이터 재구성
                vc.sendItem = { newItemName in
                    let row = value.0.row
                    newItemName
                        .map { (row, $0) }
                        .bind(to: renameItem)
                        .disposed(by: owner.disposeBag)
                }
                owner.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: disposeBag)

    }
}
