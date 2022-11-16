//
//  ViewController.swift
//  chatApp
//
//  Created by huy on 22/09/2022.
//

import FirebaseAuth
import JGProgressHUD
import UIKit

class ConversationsViewController: UIViewController {
    // MARK: Parameters - Data

    private var conversations = [Conversation]()

    // MARK: Parameters - UIKit

    private let spinner = JGProgressHUD(style: .dark)

    private let conversationstTableView: UITableView = {
        let table = UITableView()
        table.register(ConversationsTableViewCell.self, forCellReuseIdentifier: ConversationsTableViewCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.isHidden = true
        return table
    }()

    private let noConversationsLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "No Conversations!"
        lbl.textAlignment = .center
        lbl.textColor = .gray
        lbl.font = .systemFont(ofSize: 21, weight: .medium)
        lbl.isHidden = true
        return lbl
    }()

    // MARK: Methods - Override

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Chats"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground

        // setup navigation item
        let composeBtn = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeNavBarButton))
        let scanBtn = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(didTapScanNavBarButton))
        navigationItem.rightBarButtonItems = [composeBtn, scanBtn]

        // setup conversationstTableView
        conversationstTableView.delegate = self
        conversationstTableView.dataSource = self

        view.addSubview(conversationstTableView)
        view.addSubview(noConversationsLabel)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let constraints = [
            conversationstTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            conversationstTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            conversationstTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            conversationstTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
        startListeningForAllConversations()
    }

    // MARK: Methods - Data

    private func startListeningForAllConversations() {
        guard let currentUserId = UserDefaults.standard.value(forKey: "id") as? String else {
            print("Thất bại lấy thông tin người dùng hiện tại, được lưu trong bộ nhớ đệm")
            return
        }

        guard !DatabaseManager.shared.isListeningForAllConversations else {
            print("Đang lắng nghe các cuộc hội thoại của người dùng hiện tại từ csdl")
            return
        }

        DatabaseManager.shared.listenForAllConversations(ofUserWithId: currentUserId) { [weak self] result in
            switch result {
            case .success(let conversations):
                self?.conversations = conversations
                DispatchQueue.main.async {
                    self?.updateUI()
                }
            case .failure(let error):
                print("Thất bại lắng nghe các cuộc hội thoại của người dùng hiện tại từ csdl: \(error)")
            }
        }
    }

    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = Login_RegisterViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }

    // MARK: Methods - UI

    private func updateUI() {
        conversationstTableView.reloadData()
        if conversations.isEmpty {
            conversationstTableView.isHidden = true
            noConversationsLabel.isHidden = false

        } else {
            conversationstTableView.isHidden = false
            noConversationsLabel.isHidden = true
        }
    }

    // MARK: Methods - Objective-C

    @objc private func didTapComposeNavBarButton() {
        let vc = NewConversationViewController()
        vc.completion = { [weak self] targetUser in
            self?.pushChosenPrivateConversation(withTargetUser: targetUser)
        }

        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }

    @objc private func didTapScanNavBarButton() {
        let vc = ScanQRCodeViewController()
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }

    // MARK: Methods - Utility

    private func pushChosenPrivateConversation(withTargetUser otherUser: User) {
        let chosenPrivateConversation = conversations.filter { conversation in
            if conversation.type == 0 {
                return conversation.members.contains { user in
                    user.id == otherUser.id
                }
            } else {
                return false
            }
        }

        if chosenPrivateConversation.count > 1 {
            print("Error!, có nhiều hơn một cuộc hội thoại riêng tư được chọn, \(chosenPrivateConversation)")
        } else if chosenPrivateConversation.count == 1 {
            let vc = ChatViewController(conversation: chosenPrivateConversation[0])
            navigationController?.pushViewController(vc, animated: true)
        } else if chosenPrivateConversation.count == 0 {
            let vc = ChatViewController(otherUserInPrivateConvo: otherUser)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        conversations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationsTableViewCell.identifier, for: indexPath) as! ConversationsTableViewCell
        cell.configure(with: conversations[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let conversation = conversations[indexPath.row]
        let vc = ChatViewController(conversation: conversation)
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        120
    }
}
