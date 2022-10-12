//
//  NewConversationViewController.swift
//  chatApp
//
//  Created by huy on 22/09/2022.
//

import JGProgressHUD
import UIKit

class NewConversationViewController: UIViewController {
    private let spinner = JGProgressHUD(style: .dark)

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for users..."
        return searchBar
    }()

    private let searchResultsTableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
        table.translatesAutoresizingMaskIntoConstraints = false
        table.isHidden = true
        return table
    }()

    private let noSearchResultsLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "No results..."
        lbl.textAlignment = .center
        lbl.textColor = .green
        lbl.font = .systemFont(ofSize: 21, weight: .medium)
        lbl.isHidden = true
        return lbl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Conversation"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))

        searchBar.delegate = self

        view.addSubview(searchResultsTableView)
        view.addSubview(noSearchResultsLabel)

        searchBar.becomeFirstResponder()
    }

    @objc private func dismissSelf() {
        navigationController?.dismiss(animated: true)
    }
}

extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {}
}
