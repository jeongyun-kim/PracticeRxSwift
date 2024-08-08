//
//  UIViewController + Extension.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 8/3/24.
//
import UIKit

extension UIViewController {
    func setNewScene(_ rootVC: UIViewController) {
        // 화면이 쌓이지 않은 채 등장!
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        // 가져온 windowScene의 sceneDelegate 정의
        let sceneDelegate = windowScene?.delegate as? SceneDelegate
        
        // 처음 보여질 화면 root로 설정하고 보여주기
        sceneDelegate?.window?.rootViewController = rootVC
        sceneDelegate?.window?.makeKeyAndVisible()
    }
}
