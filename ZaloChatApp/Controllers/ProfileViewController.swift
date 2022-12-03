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
    private var item: [String] = []
    init(userdata: User) {
        self.currentUser = userdata
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    // MARK: Parameters - UIKit

    private let profileTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let profileTableHeaderView: UIView = {
        let headerView = UIView(frame: .zero)
        headerView.backgroundColor = .systemBackground
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
        title = "Hồ sơ"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        
        print(currentUser)
        
        profileTableView.dataSource = self
        profileTableView.delegate = self
        profileTableView.tableHeaderView = profileTableHeaderView
        profileTableView.reloadData()
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
        profileTableHeaderView.frame = CGRect(x: 0, y: 0, width: view.width, height: 185)
        profileTableHeaderImageView.frame = CGRect(x: (profileTableHeaderView.width - 150) / 2, y: 15, width: 150, height: 150)
        profileTableHeaderImageView.layer.cornerRadius = profileTableHeaderImageView.width / 2
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //startListeningForCurrentUser()
        DispatchQueue.main.async {
            self.updateUI()
            self.item = ["Họ và tên: " + self.currentUser.name, "Email: " + self.currentUser.email,"Giới tính: " +  self.currentUser.gender,"Ngày sinh: " + self.currentUser.birthday]
            self.profileTableView.reloadData()
        }
    }

    // MARK: Methods - Data

//    private func startListeningForCurrentUser() {
//        guard let currentUserId = UserDefaults.standard.value(forKey: "id") as? String else {
//            print("Thất bại lấy thông tin người dùng hiện tại, được lưu trong bộ nhớ đệm")
//            return
//        }
//
//        guard !DatabaseManager.shared.isListeningForUser else {
//            print("Đang lắng nghe người dùng hiện tại từ csdl")
//            return
//        }
//
//        DatabaseManager.shared.listenForUser(with: currentUserId) { [weak self] result in
//            switch result {
//            case .success(let user):
//                self?.currentUser = user
//                DispatchQueue.main.async {
//                    self?.updateUI()
//                }
//            case .failure(let error):
//                print("Thất bại lắng nghe người dùng hiện tại từ csdl: \(error)")
//            }
//        }
//    }

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
