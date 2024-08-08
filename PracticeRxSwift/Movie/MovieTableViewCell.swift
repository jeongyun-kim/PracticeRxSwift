//
//  MovieTableViewCell.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 8/8/24.
//

import UIKit
import SnapKit

final class MovieTableViewCell: UITableViewCell {
    private let backView = UIView()
    private let nameLabel = UILabel()
 
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupHierarchy()
        setupConstraints()
        setupUI()
    }
    
    private func setupHierarchy() {
        contentView.addSubview(backView)
        backView.addSubview(nameLabel)
    }
    
    private func setupConstraints() {
        backView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(16)
            make.verticalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(4)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(backView.snp.leading).offset(32)
            make.centerY.equalTo(backView.snp.centerY)
        }
    }
    
    private func setupUI() {
        backView.layer.cornerRadius = 8
        backView.backgroundColor = Color.gray6
        selectionStyle = .none
    }
    
    func configureCell(_ data: String) {
        nameLabel.text = data
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
