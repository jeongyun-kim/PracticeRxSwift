//
//  PhotoCollectionViewCell.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 8/11/24.
//

import UIKit
import SnapKit
import Kingfisher

final class PhotoCollectionViewCell: UICollectionViewCell {
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarchy()
        setupConstraints()
        setupUI()
    }
    
    private func setupHierarchy() {
        contentView.addSubview(imageView)
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(contentView.safeAreaLayoutGuide).inset(2)
        }
    }
    
    private func setupUI() {
        imageView.backgroundColor = Color.lightGray
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.contentMode = .scaleAspectFill
    }
    
    func configureCell(_ data: String) {
        guard let url = URL(string: data) else { return }
        imageView.kf.setImage(with: url)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
