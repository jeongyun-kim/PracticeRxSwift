//
//  BaseViewController.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 7/30/24.
//

import UIKit

class BaseViewController: UIViewController {
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupConstraints()
        setupUI()
        bind()
    }
    
    func setupHierarchy() {
        
    }
    
    func setupConstraints() {
        
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
    }
    
    func bind() {
        
    }
    
}
