//
//  ContactsViewController.swift
//  ZaloChatApp
//
//  Created by huy on 12/10/2022.
//

import UIKit

// Tạo setion
struct ContactsSection {
    let title: String
    let options: [ContactsSectionOptionType]
}

enum ContactsSectionOptionType {
    case friendsProfileCell(model: User)
}

class ContactsViewController: UIViewController {
    
    private var models = [ContactsSection]()
    private var userList = [User(id: "", name: "Tuyet Ngoc", profilePictureUrl: "user1", isActive: true),User(id: "", name: "Dinh Long", profilePictureUrl: "user2", isActive: true),User(id: "", name: "Le Huan", profilePictureUrl: "user3", isActive: true),User(id: "", name: "Nguyen Dung", profilePictureUrl: "user4", isActive: true),User(id: "", name: "Le Ngoc Mai", profilePictureUrl: "user5", isActive: true)]



    private let contactsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(FriendsTableViewCell.self, forCellReuseIdentifier: FriendsTableViewCell.identifier)
        tableView.backgroundColor = .systemBackground
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Contacts"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Danh bạ"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground
        
        configure()
        
        contactsTableView.dataSource = self
        contactsTableView.delegate = self

        view.addSubview(contactsTableView)
    }
    

    func configure() {
        
        var loadUser: [ContactsSectionOptionType] = []
        
        for user in userList
        {
            loadUser.append(.friendsProfileCell(model: user))

        }

        models.append(ContactsSection(title: "Bạn bè", options: loadUser
         ))
        
        models.append(ContactsSection(title: "Nhóm", options: [

        ]))
        contactsTableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let constraints = [
            contactsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contactsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contactsTableView.topAnchor.constraint(equalTo: view.topAnchor),
            contactsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }
}

extension ContactsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = models[section]
        return section.title
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].options.count
         
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section].options[indexPath.row]
        
        switch model.self {
        case .friendsProfileCell(let model):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: FriendsTableViewCell.identifier,
                for: indexPath
            ) as? FriendsTableViewCell else {
                return FriendsTableViewCell()
            }
            
            cell.configure(with: model)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let type = models[indexPath.section].options[indexPath.row]
        
        switch type.self {
        case .friendsProfileCell(let model):
            return
        }
    }
}
