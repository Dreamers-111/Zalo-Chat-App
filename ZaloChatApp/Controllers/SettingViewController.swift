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
    case userProfileCell(model: User)
}

struct SettingsSwitchOption {
    let title: String
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    var isOn: Bool
    let handler: (() -> Void)
}

struct SettingsOption {
    let title: String
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    let handler: (() -> Void)
}

class SettingViewController: UIViewController {
    
    private var currentUser = User()
    
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
        title = "Cài đặt"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true

        self.startListeningForCurrentUser()

        print(currentUser.name)
        print("1")
        
        configure()
        
        settingsTableView.dataSource = self
        settingsTableView.delegate = self

        view.addSubview(settingsTableView)
    }
    
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
                    //
                }
            case .failure(let error):
                print("Thất bại lắng nghe người dùng hiện tại từ csdl: \(error)")
            }
        }
    }
    
    
    func configure() {
        let user = currentUser
        models.append(Section(title: "", options: [
            .userProfileCell(model: user)
        ]))
        
        models.append(Section(title: "Kết nối", options: [
            .switchCell(model: SettingsSwitchOption(
                title: "Chế độ máy bay", icon: UIImage(systemName: "airplane"),
                iconBackgroundColor: .systemOrange,
                isOn: false) {
                    print("Tapped 1 cell")
                }),
            
            .staticCell(model: SettingsOption(
                title: "Wi-fi", icon: UIImage(systemName: "wifi"),
                iconBackgroundColor: .systemBlue) {
                    print("Tapped 2 cell")
                }),
            
            .staticCell(model: SettingsOption(
                title: "Bluetooh", icon: UIImage(systemName: "b.circle"),
                iconBackgroundColor: .systemBlue) {
                    print("Tapped 3 cell")
                }),
            .staticCell(model: SettingsOption(
                title: "Di động", icon: UIImage(systemName: "antenna.radiowaves.left.and.right"),
                iconBackgroundColor: .systemGreen) {
                    print("Tapped 4 cell")
                }),
            .switchCell(model: SettingsSwitchOption(
                title: "VPN", icon: UIImage(systemName: "v.circle"),
                iconBackgroundColor: .systemBlue,
                isOn: false) {
                    print("Tapped 5 cell")
                }),
        ]))
        
        models.append(Section(title: "Ứng dụng", options: [
            .switchCell(model: SettingsSwitchOption(
                title: "Chế độ máy bay", icon: UIImage(systemName: "airplane"),
                iconBackgroundColor: .systemOrange,
                isOn: false) {
                    print("Tapped 1 cell")
                }),
            
            .staticCell(model: SettingsOption(
                title: "Wi-fi", icon: UIImage(systemName: "wifi"),
                iconBackgroundColor: .systemBlue) {
                    print("Tapped 2 cell")
                }),
            
            .staticCell(model: SettingsOption(
                title: "Bluetooh", icon: UIImage(systemName: "b.circle"),
                iconBackgroundColor: .systemBlue) {
                    print("Tapped 3 cell")
                }),
            .staticCell(model: SettingsOption(
                title: "Di động", icon: UIImage(systemName: "antenna.radiowaves.left.and.right"),
                iconBackgroundColor: .systemGreen) {
                    print("Tapped 4 cell")
                }),
            .switchCell(model: SettingsSwitchOption(
                title: "VPN", icon: UIImage(systemName: "v.circle"),
                iconBackgroundColor: .systemBlue,
                isOn: false) {
                    print("Tapped 5 cell")
                })
            ,
            .logoutButton
        ]))

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
                for: indexPath
            ) as? ProfileTableViewCell else {
                return UITableViewCell()
            }
            
            cell.configure(with: model)
            return cell
            
        case .staticCell(let model):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: StaticTableViewCell.identifier,
                for: indexPath
            ) as? StaticTableViewCell else {
                return UITableViewCell()
            }
            
            cell.configure(with: model)
            return cell
        case .switchCell(let model):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SwitchTableViewCell.identifier,
                for: indexPath
            ) as? SwitchTableViewCell else {
                return UITableViewCell()
            }
            
            cell.configure(with: model)
            return cell
        case .logoutButton:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: LogoutTableViewCell.identifier,
                for: indexPath
            ) as? LogoutTableViewCell else {
                return UITableViewCell()
            }
            
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let type = models[indexPath.section].options[indexPath.row]

        switch type.self {
        case .userProfileCell(let model):
            print(currentUser.name)
            return
        case .staticCell(let model):
            // action khi bấm vào
            model.handler()
        case .switchCell(let model):
            model.handler()
        case .logoutButton:
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
}
