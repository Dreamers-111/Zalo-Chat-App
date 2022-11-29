//
//  FriendsTableViewCell.swift
//  ZaloChatApp
//
//  Created by Phạm Văn Nam on 21/11/2022.
//

import UIKit

class FriendsTableViewCell: UITableViewCell {

    static let identifier = "FriendsTableViewCell"
    

    private let userProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let label : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 18, weight: .regular)
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

    required init?(coder: NSCoder) {
        fatalError()
    }
    

    private func configureContents() {
        let constraints = [
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            userProfileImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.6),
            userProfileImageView.widthAnchor.constraint(equalTo: userProfileImageView.heightAnchor),
            userProfileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            userProfileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            label.leadingAnchor.constraint(equalTo: userProfileImageView.trailingAnchor, constant: 10),
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
        userProfileImageView.kf.setImage(with: URL(string: model.profilePictureUrl))
    }


}
