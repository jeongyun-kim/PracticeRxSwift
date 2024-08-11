//
//  PhotoViewController.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 8/11/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class PhotoViewController: BaseViewController {
    override func bind() {
        let search = Search(keyword: "star", page: 1, sort: "relevant")
        do {
            let request = try URLRequestManager.search(query: search).asURLRequest()
            UnsplashNetwork.shared.fetchSearchResults(of: SearchResults.self, request: request)
        } catch {
            print("error!")
        }
    }
}
