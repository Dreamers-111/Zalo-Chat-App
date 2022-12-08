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
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let conversationNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .semibold)
        return label
    }()
    
    private let conversationMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
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
        contentView.backgroundColor = UIColor(red: 0.82, green: 0.89, blue: 0.86, alpha: 1.00)
        conversationImageView.frame = CGRect(x: 10, y: 25, width: 70, height: 70)
        
        conversationNameLabel.frame = CGRect(x: conversationImageView.right + 10,
                                             y: 25,
                                             width: contentView.width - 20 - conversationImageView.width,
                                             height: (contentView.height - 60)/2)
        
        conversationMessageLabel.frame = CGRect(x: conversationImageView.right + 10,
                                                y: conversationNameLabel.bottom,
                                                width: contentView.width - 40 - conversationImageView.width,
                                                height: (contentView.height - 60)/2)

        
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
