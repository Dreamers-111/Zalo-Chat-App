//
//  FriendsTableViewCell.swift
//  ZaloChatApp
//
//  Created by Phạm Văn Nam on 21/11/2022.
//

import UIKit

class FriendsTableViewCell: UITableViewCell {
    static let identifier = "FriendsTableViewCell"

     let userProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds =  true
        imageView.layer.cornerRadius = 0
        imageView.layer.masksToBounds = true
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        imageView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return imageView
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.numberOfLines = 1
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.layoutMargins = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
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
            userProfileImageView.leadingAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            userProfileImageView.topAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.topAnchor),
            userProfileImageView.bottomAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            userProfileImageView.widthAnchor.constraint(
                equalTo: userProfileImageView.heightAnchor),
            
            userProfileImageView.trailingAnchor.constraint(
                equalTo: label.leadingAnchor,
                constant: -20),
            label.centerYAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.centerYAnchor)

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
        userProfileImageView.image = UIImage(named: model.profilePictureUrl)!
    }
}
