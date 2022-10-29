//
//  NewConversationViewController.swift
//  chatApp
//
//  Created by huy on 22/09/2022.
//

import JGProgressHUD
import UIKit

class NewConversationViewController: UIViewController {
    private var userSearchResults = [User]()

    private let spinner = JGProgressHUD(style: .dark)

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.autocapitalizationType = .none
        searchBar.autocorrectionType = .no
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
        lbl.translatesAutoresizingMaskIntoConstraints = false
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
        searchResultsTableView.dataSource = self
        searchResultsTableView.delegate = self

        view.addSubview(searchResultsTableView)
        view.addSubview(noSearchResultsLabel)

        searchBar.becomeFirstResponder()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let constraints = [
            searchResultsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchResultsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchResultsTableView.topAnchor.constraint(equalTo: view.topAnchor),
            searchResultsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            noSearchResultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noSearchResultsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    @objc private func dismissSelf() {
        navigationController?.dismiss(animated: true)
    }
}

extension NewConversationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        userSearchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
        let result = userSearchResults[indexPath.row]
        cell.textLabel?.text = "\(result.name)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension NewConversationViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.replacingOccurrences(of: " ", with: "").isEmpty else {
            noSearchResultsLabel.isHidden = true
            searchResultsTableView.isHidden = true
            userSearchResults = []
            return
        }
        // Không cần spinner, vì mình không bấm nút
        // Không cần thiết - searchBar.resignFirstResponder(), vì mình không bấm nút
        // Gây ra lỗi index out of range - userSearchResults.removeAll()

        // searchText được truyền vào sẽ được xử lý thành mảng các String
        // Chính là từng thành phần trong tên người dùng
        DatabaseManager.shared.searchUsers(thatHaveNamesLike: searchText.lowercased()) { [weak self] result in
            switch result {
            case .success(let userResults):
                self?.userSearchResults = userResults
            case .failure(let error):
                self?.userSearchResults = []
                print(error)
            }
            self?.updateUI()
        }
    }

    private func updateUI() {
        // UPDATE UI
        DispatchQueue.main.async { [self] in
            if userSearchResults.isEmpty {
                noSearchResultsLabel.isHidden = false
                searchResultsTableView.isHidden = true
            }
            else {
                noSearchResultsLabel.isHidden = true
                searchResultsTableView.isHidden = false
                searchResultsTableView.reloadData()
            }
        }
    }
}
