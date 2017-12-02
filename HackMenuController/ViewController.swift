//
//  ViewController.swift
//  HackMenuController
//
//  Created by Jonny on 12/2/17.
//  Copyright © 2017 Jonny. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIMenuController.shared.menuItems = (1 ... 10).map {
            UIMenuItem.init(title: "Button \($0)", action: #selector(tapMenuItem))
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleViewDidMoveToSuperviewNotification), name: .viewDidMoveToSuperview, object: nil)
        
        struct Swizzle {
            static let perform: Void = {
                method_exchangeImplementations(
                    class_getInstanceMethod(UIView.self, #selector(UIView.didMoveToSuperview))!,
                    class_getInstanceMethod(UIView.self, #selector(UIView.swizzle_didMoveToSuperview))!
                )
            }()
        }
        _ = Swizzle.perform
    }
}

private extension ViewController {
    
    static let calloutBarButtonClass = NSClassFromString("UICalloutBarButton") as? UIButton.Type
    
    @objc func handleViewDidMoveToSuperviewNotification(_ notification: Notification) {
        guard let calloutBarButtonClass = ViewController.calloutBarButtonClass,
            let button = notification.object as? UIButton,
            button.isMember(of: calloutBarButtonClass),
            !button.allTargets.contains(self) else { return }
        
        button.addTarget(self, action: #selector(tapMenuItemButton), for: .touchUpInside)
    }
    
    @objc func tapMenuItemButton(_ button: UIButton) {
        print(#function, button.currentTitle ?? "N/A")
    }
    
    @objc func tapMenuItem() {}
}



@objc private extension UIView {
    func swizzle_didMoveToSuperview() {
        NotificationCenter.default.post(name: .viewDidMoveToSuperview, object: self)
        swizzle_didMoveToSuperview()
    }
}

private extension Notification.Name {
    static let viewDidMoveToSuperview = Notification.Name("ViewDidMoveToSuperviewNotification")
}
