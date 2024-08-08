//
//  ShoppingTableViewCell.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 8/3/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ShoppingTableViewCell: UITableViewCell {
    var disposeBag = DisposeBag()
    
    private let backView = UIView()
    private let completeImageView = UIImageView()
    let completeButton = UIButton()
    private let nameLabel = UILabel()
    private let bookmarkImageView = UIImageView()
    let bookmarkButton = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupHierarchy()
        setupConstraints()
        setupUI()
    }
    
    override func prepareForReuse() {
        // 다시 DisposeBag 해주지않으면 완료 표시했을 때, 다른 셀이 막 체크되는 경우가 있음 
        disposeBag = DisposeBag()
    }
    
    private func setupHierarchy() {
        contentView.addSubview(backView)
        backView.addSubview(completeImageView)
        backView.addSubview(completeButton)
        backView.addSubview(nameLabel)
        backView.addSubview(bookmarkImageView)
        backView.addSubview(bookmarkButton)
    }
    
    private func setupConstraints() {
        backView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(16)
            make.verticalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(4)
        }
        
        completeImageView.snp.makeConstraints { make in
            make.size.equalTo(20)
            make.centerY.equalTo(backView.snp.centerY)
            make.leading.equalTo(backView.snp.leading).offset(16)
        }
        
        completeButton.snp.makeConstraints { make in
            make.edges.equalTo(completeImageView)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(completeButton.snp.trailing).offset(16)
            make.centerY.equalTo(backView.snp.centerY)
        }

        bookmarkImageView.snp.makeConstraints { make in
            make.size.equalTo(20)
            make.centerY.equalTo(backView.snp.centerY)
            make.leading.greaterThanOrEqualTo(nameLabel.snp.trailing).offset(12)
            make.trailing.equalTo(backView.snp.trailing).inset(16)
        }
        
        bookmarkButton.snp.makeConstraints { make in
            make.edges.equalTo(bookmarkImageView)
        }
    }
    
    private func setupUI() {
        completeImageView.tintColor = Color.black
        completeImageView.image = UIImage(systemName: "checkmark.square")
        bookmarkImageView.tintColor = Color.black
        bookmarkImageView.image = UIImage(systemName: "star")
        backView.layer.cornerRadius = 8
        backView.backgroundColor = Color.gray6
        selectionStyle = .none
    }
    
    func configureCell(_ data: Item) {
        let completeImage = data.isComplete ? "checkmark.square.fill" : "checkmark.square"
        let bookmarkImage = data.bookmark ? "star.fill" : "star"
        bookmarkImageView.image = UIImage(systemName: bookmarkImage)
        completeImageView.image = UIImage(systemName: completeImage)
        nameLabel.text = data.name
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
