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
    private let vm = ShoppingViewModel()
    
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
        let addItem = addButton.rx.tap.withLatestFrom(itemTextField.rx.text.orEmpty)
        let removeItem = tableView.rx.itemDeleted
        let renameItem = PublishRelay<(Int, String)>()
        let completeItem = PublishRelay<Int>()
        let bookmarkItem = PublishRelay<Int>()
        let selectedItem = Observable
            .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(Item.self))
        let searchBtnTapped = navigationItem.rightBarButtonItem?.rx.tap
        let getNewItemList = PublishRelay<[Item]>()
        
        let input = ShoppingViewModel.Input(addItem: addItem, removeItem: removeItem, 
                                            renameItem: renameItem, completeItem: completeItem,
                                            bookmarkItem: bookmarkItem, selectedItem: selectedItem,
                                            searchBtnTapped: searchBtnTapped, getNewItemList: getNewItemList)
        guard let output = vm.transform(input) else { return }
        
        // 테이블뷰 셀 그리기
        output.items
            .bind(to: tableView.rx.items(cellIdentifier: ShoppingTableViewCell.identifier, cellType: ShoppingTableViewCell.self)) { (row, element, cell) in
            cell.configureCell(element)
            // 완료 버튼 눌렀을 때
                cell.completeButton.rx.tap
                    .bind { _ in
                        completeItem.accept(row)
                    }.disposed(by: cell.disposeBag)
            // 즐겨찾기 버튼 눌렀을 때
                cell.bookmarkButton.rx.tap
                    .bind { _ in
                        bookmarkItem.accept(row)
                    }.disposed(by: cell.disposeBag)
        }.disposed(by: disposeBag)
        
        // 테이블뷰 셀 선택 시 상세정보뷰 불러오기
        // - 상세정보로 현재 상품명 보내주기 
        // - 상세정보에서 상품명 수정하고 돌아오면 리스트 업데이트
        output.selectedItem
            .subscribe(with: self) { owner, value in
                // 상세정보뷰로 현재 선택한 상품명 보내기
                let itemName = value.1.name
                let vc = ShoppingDetailViewController()
                vc.itemName.accept(itemName)
                // 상세정보에서 상품명을 수정했다면 수정한 이름으로 데이터 재구성
                vc.sendItem = { newItemName in
                    renameItem.accept((value.0.row, newItemName))
                }
                owner.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: disposeBag)

        // 아이템 추가했을 때 + 기본 상태일 때 텍스트 필드 텍스트 비워두기 
        output.addedItemTrigger
            .map { "" }
            .bind(to: itemTextField.rx.text)
            .disposed(by: disposeBag)
        
        output.searchBtnTapped
            .bind(with: self) { owner, _ in
                let vc = ShoppingSearchViewController()
                vc.vm.list.accept(output.items.value)
                vc.sendList = { list in
                    getNewItemList.accept(list)
                }
                owner.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: disposeBag)
            
    }
    
    private func configureNavigation() {
        navigationItem.title = "쇼핑"
        let search = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: nil)
        navigationItem.rightBarButtonItem = search
    }
}
