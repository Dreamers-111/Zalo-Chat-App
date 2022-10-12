//
//  ViewController.swift
//  ZaloChatApp
//
//  Created by huy on 27/09/2022.
//

import UIKit


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let isLoginIn = UserDefaults.standard.bool(forKey: "logged_in")
        
        if !isLoginIn {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav,animated: false)
        }
    }

}

