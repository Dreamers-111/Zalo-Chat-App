//
//  MainTabBarViewController.swift
//  ZaloChatApp
//
//  Created by huy on 05/10/2022.
//

import UIKit

class MainTabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let vc1 = ConversationsViewController()
        let vc2 = ContactsViewController()
        let vc3 = TimelineViewController()
        let vc4 = ProfileViewController()

        let nav1 = UINavigationController(rootViewController: vc1)
        let nav2 = UINavigationController(rootViewController: vc2)
        let nav3 = UINavigationController(rootViewController: vc3)
        let nav4 = UINavigationController(rootViewController: vc4)

        nav1.tabBarItem = UITabBarItem(title: "Messages", image: UIImage(systemName: "message"), selectedImage: UIImage(systemName: "message.fill"))
        nav2.tabBarItem = UITabBarItem(title: "Contacts", image: UIImage(systemName: "person.2.circle"), selectedImage: UIImage(systemName: "person.2.circle.fill"))
        nav3.tabBarItem = UITabBarItem(title: "Timeline", image: UIImage(systemName: "clock"), selectedImage: UIImage(systemName: "clock.fill"))
        nav4.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person.fill"))

        tabBar.tintColor = .tintColor
        setViewControllers([nav1, nav2, nav3, nav4], animated: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        selectedIndex = 0
    }
}
