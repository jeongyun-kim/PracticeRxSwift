//
//  Item.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 8/3/24.
//

import Foundation

struct Item {
    var name: String
    var isComplete: Bool = false
    var bookmark: Bool = false
}

struct ItemList {
    let list: [Item] = [
        Item(name: "플래너"),
        Item(name: "바인더"),
        Item(name: "스티커")
    ]
}
