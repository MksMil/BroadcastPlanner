//
//  UIKit+ext.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 28.02.2024.
//

import UIKit

@MainActor
func topViewController(controller: UIViewController? = nil) -> UIViewController? {
    
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return nil }
    
    guard let rootviewcontroller = windowScene.windows.first?.rootViewController else { return nil}
    
    if let navigationController = rootviewcontroller as? UINavigationController {
        return topViewController(controller: navigationController.visibleViewController)
    }
    
    if let tabController = rootviewcontroller as? UITabBarController {
        if let selected = tabController.selectedViewController {
            return topViewController(controller: selected)
        }
    }
    if let presented = rootviewcontroller.presentedViewController {
        return topViewController(controller: presented)
    }
    return rootviewcontroller
}


// MARK: - .navigationBarBackButtonHidden() backSwipe fix
extension UINavigationController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = nil
    }
}
