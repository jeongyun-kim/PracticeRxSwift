//
//  ViewModel.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 8/11/24.
//

import Foundation

protocol ViewModel {
    associatedtype Input
    associatedtype Output
    
    func transform(_ input: Input) -> Output
}
