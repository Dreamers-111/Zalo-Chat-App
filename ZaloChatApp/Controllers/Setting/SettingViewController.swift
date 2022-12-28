//
//  SettingViewController.swift
//  chatApp
//
//  Created by Nam on 22/09/2022.
//

import FirebaseAuth
import GoogleSignIn
import UIKit

// Tạo setion
struct Section {
    let title: String
    let options: [SettingsOptionType]
}

enum SettingsOptionType {
    case staticCell(model: SettingsOption)
    case switchCell(model: SettingsSwitchOption)
    case logoutButton
    case userProfileCell(model: SettingViewController.CurrentUser)
}

struct SettingsSwitchOption {
    let title: String
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    var isOn: Bool
    let handler: () -> Void
}

struct SettingsOption {
    let title: String
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    let handler: () -> Void
}

class SettingViewController: UIViewController {
    struct CurrentUser {
        var id: String
        var name: String
        var profilePictureUrl: String
    }

    private let db = DatabaseManager.shared

    private let currentUser: CurrentUser = {
        guard let currentUserId = Defaults.currentUser[.id],
              let currentUserName = Defaults.currentUser[.name],
              let currentUserPictureUrl = Defaults.currentUser[.profilePictureUrl]
        else {
            return CurrentUser(id: "", name: "", profilePictureUrl: "")
        }
        return CurrentUser(id: currentUserId,
                           name: currentUserName,
                           profilePictureUrl: currentUserPictureUrl)
    }()

    private var models = [Section]()

    private let settingsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(StaticTableViewCell.self, forCellReuseIdentifier: StaticTableViewCell.identifier)
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: SwitchTableViewCell.identifier)
        tableView.register(LogoutTableViewCell.self, forCellReuseIdentifier: LogoutTableViewCell.identifier)
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.identifier)
        tableView.backgroundColor = .systemBackground
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        configureNavigationView()
        configureSettingsTableView()

        view.addSubview(settingsTableView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let constraints = [
            settingsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            settingsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            settingsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            settingsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func configureNavigationView() {
        navigationItem.title = "Cài đặt"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func configureSettingsTableView() {
        models.append(Section(title: "", options: [
            .userProfileCell(model: currentUser)
        ]))

        models.append(Section(title: "", options: [
            .staticCell(model: SettingsOption(
                title: "Tài khoản và bảo mật", icon: UIImage(systemName: "person.badge.shield.checkmark.fill"),
                iconBackgroundColor: .systemBlue)
            {
                print("'Tài khoản và bảo mật' cell tapped")
            }),

            .staticCell(model: SettingsOption(
                title: "Quyền riêng tư", icon: UIImage(systemName: "lock.fill"),
                iconBackgroundColor: .systemBlue)
            {
                print("'Quyền riêng tư' cell tapped")
            })
        ]))

        models.append(Section(title: "", options: [
            .logoutButton]))

        settingsTableView.dataSource = self
        settingsTableView.delegate = self
    }
}

extension SettingViewController: UITableViewDataSource, UITableViewDelegate {

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
        case .userProfileCell(let model):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ProfileTableViewCell.identifier,
                for: indexPath) as? ProfileTableViewCell
            else {
                return UITableViewCell()
            }

            cell.configure(with: model)
            return cell

        case .staticCell(let model):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: StaticTableViewCell.identifier,
                for: indexPath) as? StaticTableViewCell
            else {
                return UITableViewCell()
            }

            cell.configure(with: model)
            return cell
        case .switchCell(let model):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SwitchTableViewCell.identifier,
                for: indexPath) as? SwitchTableViewCell
            else {
                return UITableViewCell()
            }

            cell.configure(with: model)
            return cell
        case .logoutButton:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: LogoutTableViewCell.identifier,
                for: indexPath) as? LogoutTableViewCell
            else {
                return UITableViewCell()
            }

            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let type = models[indexPath.section].options[indexPath.row]

        switch type.self {
        case .userProfileCell:
            let vc = ProfileViewController()
            navigationController?.pushViewController(vc, animated: true)
            return
        case .staticCell(let model):
            // action khi bấm vào
            model.handler()
        case .switchCell(let model):
            model.handler()
        case .logoutButton:
            let actionSheet = UIAlertController(title: "", message: "Do you really want to log out?", preferredStyle: .actionSheet)

            actionSheet.addAction(UIAlertAction(title: "Xác nhận đăng xuất", style: .destructive) { [weak self] _ in
                GIDSignIn.sharedInstance.signOut()
                do {
                    try FirebaseAuth.Auth.auth().signOut()
                    let vc = Login_RegisterViewController()
                    let nav = UINavigationController(rootViewController: vc)
                    nav.modalPresentationStyle = .fullScreen
                    self?.present(nav, animated: true) {
                        Defaults.currentUser.removeValue(forKey: .id)
                        Defaults.currentUser.removeValue(forKey: .name)
                        Defaults.currentUser.removeValue(forKey: .profilePictureUrl)
                        NotificationCenter.default.post(name: .didSignOut, object: nil)
                    }
                } catch {
                    print("Đăng xuất thất bại", error.localizedDescription)
                }
            })

            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

            present(actionSheet, animated: true)
        }
    }
}
