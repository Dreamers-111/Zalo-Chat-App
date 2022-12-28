//
//  CustomMessageCollectionViewCell.swift
//  ZaloChatApp
//
//  Created by huy on 13/12/2022.
//

import MessageKit
import UIKit

class CustomMessageCollectionViewCell: UICollectionViewCell {
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.italicSystemFont(ofSize: 13)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews() {
        contentView.addSubview(label)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = contentView.bounds
    }

    func configure(with message: MessageType, at _: IndexPath, and _: MessagesCollectionView) {
        // Do stuff
        if case .custom(let data) = message.kind {
            guard let systemMessage = data as? String else { return }
            label.text = systemMessage
        }
    }
}
