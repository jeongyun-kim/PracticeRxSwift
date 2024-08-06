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
        var list: [Item]
        let items: BehaviorRelay<[Item]>
        let addedItemTrigger: BehaviorRelay<Void>
        let selectedItem: Observable<(ControlEvent<IndexPath>.Element, ControlEvent<Item>.Element)>
        let searchBtnTapped: ControlEvent<()>
    }
    
    func transform(_ input: Input) -> Output? {
        var list = ItemList().list
        let items = BehaviorRelay(value: list)
        let addedItemTrigger = BehaviorRelay(value: ())
        guard let tap = input.searchBtnTapped else { return nil }
        
        input.addItem
            .bind(onNext: { itemName in
                let item = Item(name: itemName)
                list.insert(item, at: 0)
                items.accept(list)
                addedItemTrigger.accept(())
            }).disposed(by: disposeBag)
        
        input.removeItem
            .bind { indexPath in
                list.remove(at: indexPath.row)
                items.accept(list)
            }.disposed(by: disposeBag)
        
        input.renameItem
            .bind { (idx, newItemName) in
                list[idx].name = newItemName
                items.accept(list)
            }.disposed(by: disposeBag)
        
        input.completeItem
            .bind { idx in
                list[idx].isComplete.toggle()
                items.accept(list)
            }.disposed(by: disposeBag)
        
        input.bookmarkItem
            .bind { idx in
                list[idx].bookmark.toggle()
                items.accept(list)
            }.disposed(by: disposeBag)
        
        input.getNewItemList
            .bind { itemList in
                list = itemList
                items.accept(list)
            }.disposed(by: disposeBag)
        
        let output = Output(list: list, items: items, addedItemTrigger: addedItemTrigger,
                            selectedItem: input.selectedItem, searchBtnTapped: tap)
        return output
    }
}
