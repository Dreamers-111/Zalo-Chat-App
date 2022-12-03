//
//  LogoutTableViewCell.swift
//  ZaloChatApp
//
//  Created by Phạm Văn Nam on 28/10/2022.
//

import UIKit

class LogoutTableViewCell: UITableViewCell {

    static let identifier = "LogoutTableViewCell"
    
    private let label : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.text = "Đăng xuất"
        label.textColor = .red
        label.font = .systemFont(ofSize: 22, weight: .regular)
        return label
    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        // layout
        configureContents()
        
        contentView.clipsToBounds = true
        accessoryType = .none
        
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    

    private func configureContents() {
        let constraints = [
            
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),

            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
        ]
        
        NSLayoutConstraint.activate(constraints)

    }
    

}
