//
//  ConversationsTableViewCell.swift
//  ZaloChatApp
//
//  Created by huy on 27/09/2022.
//

import UIKit

class ConversationsTableViewCell: UITableViewCell {
    static let identifier = "ConversationsTableViewCell"
    
    private let conversationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let conversationNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    private let conversationMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(conversationImageView)
        contentView.addSubview(conversationNameLabel)
        contentView.addSubview(conversationMessageLabel)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        conversationImageView.frame = CGRect(x: 10, y: 10, width: 100, height: 100)
        
        conversationNameLabel.frame = CGRect(x: conversationImageView.right + 10,
                                             y: 10,
                                             width: contentView.width - 20 - conversationImageView.width,
                                             height: (contentView.height - 20)/2)
        
        conversationMessageLabel.frame = CGRect(x: conversationImageView.right + 10,
                                                y: conversationNameLabel.bottom + 10,
                                                width: contentView.width - 20 - conversationImageView.width,
                                                height: (contentView.height - 20)/2)
    }
    
    func configure(with convo: Conversation) {
        if convo.displayPictureUrl.isEmpty {
            conversationImageView.image = UIImage(named: "default_avatar")
        }
        else {
            conversationImageView.kf.setImage(with: URL(string: convo.displayPictureUrl))
        }
        conversationNameLabel.text = convo.displayName
        
        conversationMessageLabel.text = convo.displayMessage
    }
}
