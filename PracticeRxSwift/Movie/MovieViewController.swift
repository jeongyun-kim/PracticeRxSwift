//
//  MovieViewController.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 8/8/24.
//

import UIKit
import SnapKit
import Toast
import RxSwift
import RxCocoa

final class MovieViewController: BaseViewController {
    private let searchController = UISearchController()
    private let disposeBag = DisposeBag()
    private let vm = MovieViewModel()
    private lazy var tableView = UITableView()
    
    override func setupHierarchy() {
        view.addSubview(tableView)
    }
    
    override func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func setupUI() {
        super.setupUI()
        navigationItem.title = "영화검색"
        navigationItem.searchController = searchController
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: MovieTableViewCell.identifier)
        tableView.rowHeight = 70
    }
    
    override func bind() {
        let keyword = searchController.searchBar.rx.text.orEmpty
        let searchBtnTapped = searchController.searchBar.rx.searchButtonClicked.withLatestFrom(keyword)
        let cancelBtnTapped = searchController.searchBar.rx.cancelButtonClicked

        let input = MovieViewModel.Input(searchBtnTapped: searchBtnTapped, cancelBtnTapped: cancelBtnTapped)
        let output = vm.transform(input)
        
        output.movieList
            .drive(tableView.rx.items(cellIdentifier: MovieTableViewCell.identifier, cellType: MovieTableViewCell.self)) { (row, element, cell) in
                cell.configureCell(element.movieNm)
            }.disposed(by: disposeBag)
        
        output.errorMessage
            .drive(with: self) { owner, errorMessage in
                owner.view.makeToast(errorMessage)
            }.disposed(by: disposeBag)
    }
    
    private func layout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(1), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 4, leading: 16, bottom: 4, trailing: 0)
        section.interGroupSpacing = 6
        section.orthogonalScrollingBehavior = .continuous
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
}
