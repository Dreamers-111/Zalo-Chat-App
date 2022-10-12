//
//  TimelineViewController.swift
//  ZaloChatApp
//
//  Created by huy on 12/10/2022.
//

import UIKit

class TimelineViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Timeline"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
    }
}
