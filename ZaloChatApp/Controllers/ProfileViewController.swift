//
//  ProfileViewController.swift
//  chatApp
//
//  Created by huy on 22/09/2022.
//

import FirebaseAuth
import GoogleSignIn
import UIKit

class ProfileViewController: UIViewController {
    private let profileTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Profile"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true

        profileTableView.dataSource = self
        profileTableView.delegate = self
        profileTableView.tableHeaderView = createTableHeader()
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
    }

    private func createTableHeader() -> UIView? {
        guard let emailAddress = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }

        let safeEmailAddress = emailAddress.replacingOccurrences(of: "-", with: ".")

        let fileName = "\(safeEmailAddress)_profile_picture.png"
        let path = "images/\(fileName)"

        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 300))
        headerView.backgroundColor = .link

        let imageView = UIImageView(frame: CGRect(x: (headerView.width - 150) / 2, y: 75, width: 150, height: 150))
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.cornerRadius = imageView.width / 2
        imageView.layer.masksToBounds = true
        headerView.addSubview(imageView)

        StorageManager.shared.downloadURL(for: path) { [weak self] result in
            switch result {
            case .success(let url):
                self?.downloadImage(for: imageView, with: url)
            case .failure(let error):
                print("Storage Errors: \(error)")
            }
        }

        return headerView
    }

    private func downloadImage(for imageView: UIImageView, with url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
            }
        }.resume()
    }
}

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
                self?.present(nav, animated: true)
            }
            catch {
                print("Failed to Log Out", error.localizedDescription)
            }
        })

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(actionSheet, animated: true)
    }
}
