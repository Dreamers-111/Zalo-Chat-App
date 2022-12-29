//
//  ProfileTableViewCell.swift
//  ZaloChatApp
//
//  Created by Phạm Văn Nam on 28/10/2022.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
    static let identifier = "ProfileTableViewCell"

    private let userProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 32
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 20, weight: .regular)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(userProfileImageView)

        // layout
        configureContents()

        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    private func configureContents() {
        let constraints = [
            contentView.heightAnchor.constraint(equalToConstant: 80),

            userProfileImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.8),
            userProfileImageView.widthAnchor.constraint(equalTo: userProfileImageView.heightAnchor),
            userProfileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            userProfileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            label.leadingAnchor.constraint(equalTo: userProfileImageView.trailingAnchor, constant: 15),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ]

        NSLayoutConstraint.activate(constraints)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        userProfileImageView.image = nil
        label.text = nil
    }

    public func configure(with model: User) {
        label.text = model.name
        userProfileImageView.kf.setImage(with: URL(string: model.profilePictureUrl),
                                         placeholder: UIImage(named: "default_avatar"))
    }
}
