//
//  ShoppingSearchViewModel.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 8/6/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ShoppingSearchViewModel {
    private enum Update {
        case complete
        case bookmark
        case remove
        case rename(newName: String)
    }
    
    private let disposeBag = DisposeBag()
    var list: BehaviorRelay<[Item]> = BehaviorRelay(value: [])
    
    struct Input {
        let searchKeyword: ControlProperty<String>
        let completeItem: PublishRelay<Int>
        let bookmarkItem: PublishRelay<Int>
        let renameItem: PublishRelay<(Int, String)>
        let removeItem: ControlEvent<IndexPath>
        let selectedItem: Observable<(ControlEvent<IndexPath>.Element, ControlEvent<Item>.Element)>
    }
    
    struct Output {
        let items: BehaviorRelay<[Item]>
        let selectedItem: Observable<(ControlEvent<IndexPath>.Element, ControlEvent<Item>.Element)>
    }
    
    func transform(_ input: Input) -> Output {
        let items = BehaviorRelay(value: list.value)
        
        input.searchKeyword
            .bind(with: self) { owner, keyword in
                let result = owner.setItems(keyword: keyword)
                items.accept(result)
            }.disposed(by: disposeBag)
        
        input.completeItem
            .bind(with: self) { owner, row in
                owner.updateItems(items: items, row: row, updateType: .complete)
                guard let idx = owner.getItemIdxFromList(item: items.value[row]) else { return }
                owner.updateOriginalData(idx, updateType: .complete)
            }.disposed(by: disposeBag)
    
        input.bookmarkItem
            .bind(with: self) { owner, row in
                owner.updateItems(items: items, row: row, updateType: .bookmark)
                guard let idx = owner.getItemIdxFromList(item: items.value[row]) else { return }
                owner.updateOriginalData(idx, updateType: .bookmark)
            }.disposed(by: disposeBag)
        
        input.removeItem
            .bind(with: self) { owner, indexPath in
                let row = indexPath.row
                owner.updateOriginalData(row, updateType: .remove)
                owner.updateItems(items: items, row: row, updateType: .remove)
            }.disposed(by: disposeBag)
        
        input.renameItem
            .bind(with: self) { owner, value in
                let row = value.0
                let newItemName = value.1
                owner.updateOriginalData(row, updateType: .rename(newName: newItemName))
                owner.updateItems(items: items, row: row, updateType: .rename(newName: newItemName))
            }.disposed(by: disposeBag)
        
        let output = Output(items: items, selectedItem: input.selectedItem)
        return output
    }
    
    // MARK: 데이터 처리
    // 현재 키워드에 따라 보여지는 데이터 리스트 다르게
    private func setItems(keyword: String) -> [Item] {
        if keyword.isEmpty {
            return list.value
        } else {
            let filteredList = list.value.filter { $0.name.contains(keyword) }
            return filteredList
        }
    }
    
    // 현재 업데이트를 할 데이터가 찐데이터들중에서 몇 번째에 있는지
    private func getItemIdxFromList(item: Item) -> Int? {
        guard let itemIdx = list.value.firstIndex(where: { $0.name == item.name }) else { return nil }
        return itemIdx
    }
    
    // 찐리스트 업데이트
    private func updateOriginalData(_ idx: Int, updateType: Update) {
        var currentList = list.value
        
        switch updateType {
        case .complete:
            currentList[idx].isComplete.toggle()
        case .bookmark:
            currentList[idx].bookmark.toggle()
        case .remove:
            currentList.remove(at: idx)
        case .rename(let newName):
            currentList[idx].name = newName
        }
        
        list.accept(currentList)
    }
    
    // 보여지고 있는 데이터 리스트 업데이트
    private func updateItems(items: BehaviorRelay<[Item]>, row: Int, updateType: Update) {
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
        
        //return currentItems
        // 보여지는 데이터 리스트 업데이트
        items.accept(currentItems)
    }
}
