//
//  ShoppingViewModel.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 8/5/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ShoppingViewModel {
    enum Update {
        case add(itemName: String)
        case complete
        case bookmark
        case rename(newItemName: String)
        case remove
    }
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let addItem: Observable<ControlProperty<String>.Element>
        let removeItem: ControlEvent<IndexPath>
        let renameItem: PublishRelay<(Int, String)>
        let completeItem: PublishRelay<Int>
        let bookmarkItem: PublishRelay<Int>
        let selectedItem: Observable<(ControlEvent<IndexPath>.Element, ControlEvent<Item>.Element)>
        let searchBtnTapped: ControlEvent<()>?
        let getNewItemList: PublishRelay<[Item]>
    }
    
    struct Output {
        let items: BehaviorRelay<[Item]>
        let addedItemTrigger: BehaviorRelay<Void>
        let selectedItem: Observable<(ControlEvent<IndexPath>.Element, ControlEvent<Item>.Element)>
        let searchBtnTapped: ControlEvent<()>
    }
    
    func transform(_ input: Input) -> Output? {
        let items = BehaviorRelay(value: ItemList().list)
        let addedItemTrigger = BehaviorRelay(value: ())
        guard let searchBtnTapped = input.searchBtnTapped else { return nil }
        
        input.addItem
            .bind(with: self) { owner, itemName in
                owner.updateItems(items: items, updateType: .add(itemName: itemName))
                addedItemTrigger.accept(())
            }.disposed(by: disposeBag)
        
        input.removeItem
            .bind(with: self) { owner, indexPath in
                owner.updateItems(items: items, row: indexPath.row, updateType: .remove)
            }.disposed(by: disposeBag)
        
        input.renameItem
            .bind(with: self) { owner, value in
                let idx = value.0
                let newItemName = value.1
                owner.updateItems(items: items, row: idx, updateType: .rename(newItemName: newItemName))
            }.disposed(by: disposeBag)
        
        input.completeItem
            .bind(with: self) { owner, idx in
                owner.updateItems(items: items, row: idx, updateType: .complete)
            }.disposed(by: disposeBag)
        
        input.bookmarkItem
            .bind(with: self) { owner, idx in
                owner.updateItems(items: items, row: idx, updateType: .bookmark)
            }.disposed(by: disposeBag)
        
        input.getNewItemList
            .bind(with: self) { owner, itemList in
                items.accept(itemList)
            }.disposed(by: disposeBag)
        
        let output = Output(items: items, addedItemTrigger: addedItemTrigger,
                            selectedItem: input.selectedItem, searchBtnTapped: searchBtnTapped)
        return output
    }
    
    // 보여지고 있는 데이터 리스트 업데이트
    private func updateItems(items: BehaviorRelay<[Item]>, row: Int = 0, updateType: Update) {
        // 현재 보여지고 있는 데이터 리스트
        var currentItems = items.value
        
        switch updateType {
        case .add(let itemName):
            let item = Item(name: itemName)
            currentItems.insert(item, at: row)
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
