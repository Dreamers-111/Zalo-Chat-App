//
//  ContactsViewController.swift
//  ZaloChatApp
//
//  Created by huy on 12/10/2022.
//

import UIKit

class ContactsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Contacts"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
    }
}
