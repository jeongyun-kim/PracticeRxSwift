//
//  TagCollectionViewCell.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 8/7/24.
//

import UIKit
import SnapKit

final class TagCollectionViewCell: UICollectionViewCell {
    private let bgView = UIView()
    private let tagLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarhchy()
        setupConstraints()
        setupUI()
    }

    private func setupHierarhchy() {
        contentView.addSubview(bgView)
        bgView.addSubview(tagLabel)
    }
    
    private func setupConstraints() {
        bgView.snp.makeConstraints { make in
            make.edges.equalTo(contentView.safeAreaLayoutGuide)
        }
        
        tagLabel.snp.makeConstraints { make in
            make.edges.equalTo(bgView.safeAreaLayoutGuide).inset(8)
        }
    }
    
    private func setupUI() {
        tagLabel.font = .systemFont(ofSize: 15)
        
        bgView.clipsToBounds = true
        bgView.layer.cornerRadius = 12
        bgView.backgroundColor = Color.gray6
    }
    
    func configureCell(_ data: String) {
        tagLabel.text = data
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
