//
//  ProfileViewController.swift
//  chatApp
//
//  Created by huy on 22/09/2022.
//

import FirebaseAuth
import GoogleSignIn
import Kingfisher
import UIKit

class ProfileViewController: UIViewController {
    // MARK: Parameters - Data

    private var currentUser = User()

    // MARK: Parameters - UIKit

    private let profileTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let profileTableHeaderView: UIView = {
        let headerView = UIView(frame: .zero)
        headerView.backgroundColor = .link
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

    // MARK: Methods - Override

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Profile"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true

        profileTableView.dataSource = self
        profileTableView.delegate = self
        profileTableView.tableHeaderView = profileTableHeaderView

        view.addSubview(profileTableView)
        profileTableHeaderView.addSubview(profileTableHeaderImageView)
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
        profileTableHeaderView.frame = CGRect(x: 0, y: 0, width: view.width, height: 300)
        profileTableHeaderImageView.frame = CGRect(x: (profileTableHeaderView.width - 150) / 2, y: 75, width: 150, height: 150)
        profileTableHeaderImageView.layer.cornerRadius = profileTableHeaderImageView.width / 2
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startListeningForCurrentUser()
    }

    // MARK: Methods - Data

    private func startListeningForCurrentUser() {
        guard let currentUserId = UserDefaults.standard.value(forKey: "id") as? String else {
            print("Thất bại lấy thông tin người dùng hiện tại, được lưu trong bộ nhớ đệm")
            return
        }

        guard !DatabaseManager.shared.isListeningForUser else {
            print("Đang lắng nghe người dùng hiện tại từ csdl")
            return
        }

        DatabaseManager.shared.listenForUser(with: currentUserId) { [weak self] result in
            switch result {
            case .success(let user):
                self?.currentUser = user
                DispatchQueue.main.async {
                    self?.updateUI()
                }
            case .failure(let error):
                print("Thất bại lắng nghe người dùng hiện tại từ csdl: \(error)")
            }
        }
    }

    // MARK: Methods - UI

    private func updateUI() {
        if currentUser.profilePictureUrl.isEmpty {
            profileTableHeaderImageView.image = UIImage(named: "default_avatar")
        } else {
            profileTableHeaderImageView.kf.setImage(with: URL(string: currentUser.profilePictureUrl))
        }
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
        cell.textLabel?.text = "Log out"
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let actionSheet = UIAlertController(title: "", message: "Do you really want to log out?", preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive) { [weak self] _ in
            GIDSignIn.sharedInstance.signOut()
            do {
                try FirebaseAuth.Auth.auth().signOut()
                let vc = Login_RegisterViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self?.present(nav, animated: true) {
                    UserDefaults.standard.removeObject(forKey: "id")
                    UserDefaults.standard.removeObject(forKey: "name")
                    UserDefaults.standard.removeObject(forKey: "profile_picture_url")
                    DatabaseManager.shared.removeAllListeners()
                }
            } catch {
                print("Đăng xuất thất bại", error.localizedDescription)
            }
        })

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(actionSheet, animated: true)
    }
}
