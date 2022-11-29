//
//  SettingTableViewCell.swift
//  ZaloChatApp
//
//  Created by Phạm Văn Nam on 27/10/2022.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {

    static let identifier = "SwitchTableViewCell"
    
    private let iconContainer : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let label : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        return label
    }()
    private let mySwitch: UISwitch = {
        let mySwitch = UISwitch()
        mySwitch.translatesAutoresizingMaskIntoConstraints = false
        mySwitch.onTintColor = .systemBlue
        return mySwitch
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(iconContainer)
        contentView.addSubview(iconImageView)
        contentView.addSubview(mySwitch)
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
            
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            
            iconContainer.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.6),
            iconContainer.widthAnchor.constraint(equalTo: iconContainer.heightAnchor),
            iconContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            iconContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            label.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 5),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            mySwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mySwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            mySwitch.heightAnchor.constraint(equalTo: iconContainer.heightAnchor)
            
        ]
        

        NSLayoutConstraint.activate(constraints)

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        label.text = nil
        iconContainer.backgroundColor = nil
        mySwitch.isOn = false
    }
    
    public func configure(with model: SettingsSwitchOption) {
        label.text = model.title
        iconImageView.image = model.icon
        iconContainer.backgroundColor = model.iconBackgroundColor
        mySwitch.isOn = model.isOn
    }
}
