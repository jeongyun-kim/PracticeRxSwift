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
    private let disposeBag = DisposeBag()
    private let vm = PhotoViewModel()
    private let searchController = UISearchController()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout())
    
    override func setupHierarchy() {
        view.addSubview(collectionView)
    }
    
    override func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func setupUI() {
        super.setupUI()
        navigationItem.title = "사진 검색"
        navigationItem.searchController = searchController
        searchController.automaticallyShowsCancelButton = false
        searchController.hidesNavigationBarDuringPresentation = false
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
    }
    
    override func bind() {
        let searchKeyword = searchController.searchBar.rx.text.orEmpty
        let searchBtnTapped = searchController.searchBar.rx.searchButtonClicked.withLatestFrom(searchKeyword)
        let prefetchIdxs = collectionView.rx.prefetchItems
        
        let input = PhotoViewModel.Input(searchBtnTapped: searchBtnTapped, prefetchIdxs: prefetchIdxs)
        let output = vm.transform(input)
        
        // 검색결과 받아와서 CollectionView 구성
        output.searchResults
            .asDriver(onErrorJustReturn: [])
            .drive(collectionView.rx.items(cellIdentifier: PhotoCollectionViewCell.identifier, cellType: PhotoCollectionViewCell.self)) { (row, element, cell) in
                cell.configureCell(element.urls.small)
            }.disposed(by: disposeBag)
        
        // 스크롤 위로 보내라는 신호 받아올 때 
        output.scrollToTop
            .asSignal(onErrorJustReturn: false)
            .emit(with: self) { owner, value in
                guard value else { return }
                owner.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
            }.disposed(by: disposeBag)
    }
    
    private func layout() -> UICollectionViewLayout {
        let spacing: CGFloat = 4
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.45))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
    
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}
