//
//  ProfileViewController.swift
//  chatApp
//
//  Created by huy on 22/09/2022.
//

import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import Kingfisher
import UIKit

class ProfileViewController: UIViewController {
    private let db = DatabaseManager.shared

    // MARK: Listeners

    private var currentUserListeners: ListenerRegistration?

    // MARK: Parameters - Data

    private var currentUser = User()

    private var item = [String]()

    // MARK: Parameters - UIKit

    private let profileTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let profileTableHeaderView: UIView = {
        let headerView = UIView(frame: .zero)
        headerView.backgroundColor = .white
        headerView.layer.cornerRadius = 10
        return headerView
    }()

    private let profileTableHeaderImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.image = UIImage(named: "default_avatar")
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        return imageView
    }()

    // MARK: Deinit

    deinit {
        if currentUserListeners?.remove() != nil {
            currentUserListeners = nil
        }
    }

    // MARK: Methods - Override

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        startListeningForCurrentUser()
        configureNavigationView()
        configureProfileTableView()

        view.addSubview(profileTableView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let constraints = [
            profileTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            profileTableView.topAnchor.constraint(equalTo: view.topAnchor),
            profileTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        //
        profileTableHeaderView.frame = CGRect(x: 0, y: 0, width: view.width, height: 185)
        profileTableHeaderImageView.frame = CGRect(x: (profileTableHeaderView.width - 150) / 2, y: 15, width: 150, height: 150)
        profileTableHeaderImageView.layer.cornerRadius = profileTableHeaderImageView.width / 2
    }

    // MARK: Methods - UI

    private func configureNavigationView() {
        navigationItem.title = "Thông tin cá nhân"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func configureProfileTableView() {
        profileTableView.dataSource = self
        profileTableView.delegate = self
        profileTableView.tableHeaderView = profileTableHeaderView
        profileTableHeaderView.addSubview(profileTableHeaderImageView)
    }

    private func updateProfileTableView() {
        item = ["Họ và tên: " + currentUser.name,
                "Email: " + currentUser.email,
                "Giới tính: " + currentUser.gender,
                "Ngày sinh: " + currentUser.birthday]
        profileTableView.reloadData()
    }

    private func updateProfileImage() {
        profileTableHeaderImageView.kf.setImage(with: URL(string: currentUser.profilePictureUrl),
                                                placeholder: UIImage(named: "default_avatar"))
    }

    private func resetProfileImage() {
        profileTableHeaderImageView.image = UIImage(named: "default_avatar")
    }

    private func startListeningForCurrentUser() {
        guard let currentUserId = Defaults.currentUser[.id] else {
            print("Thất bại lắng nghe người dùng hiện tại")
            return
        }

        currentUserListeners = db.listenForUser(with: currentUserId) { [weak self] result in
            switch result {
            case .success(let user):
                self?.currentUser = user
                DispatchQueue.main.async {
                    self?.updateProfileImage()
                    self?.updateProfileTableView()
                }
            case .failure(let error):
                print("Thất bại lắng nghe người dùng hiện tại: \(error)")
            }
        }
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        item.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
        cell.textLabel?.text = item[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
