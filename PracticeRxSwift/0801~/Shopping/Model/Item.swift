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
        Item(name: "스티커"),
        Item(name: "헬로키티 콜라보 인형"),
        Item(name: "귀여운 댕댕이인형"),
        Item(name: "철수 인형"),
        Item(name: "북커버"),
        Item(name: "책갈피"),
        Item(name: "복숭아"),
        Item(name: "커피"),
        Item(name: "망고")
    ]
}
