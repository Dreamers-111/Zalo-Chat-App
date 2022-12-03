//
//  PageViewCell.swift
//  ZaloChatApp
//
//  Created by Phan Tam Nhu on 08/10/2022.
//

import UIKit

struct SwipePageModel {
    let imageName: String
    let headerText: String
    let bodyText: String
}

class PageViewCell: UICollectionViewCell {
    var page: SwipePageModel? {
        didSet {
            guard let unwrappedPage = page else { return }
            swipingImageView.image = UIImage(named: unwrappedPage.imageName)
            let attributedText = NSMutableAttributedString(string: unwrappedPage.headerText,
                                                           attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)])
            attributedText.append(NSAttributedString(string: "\n\n\(unwrappedPage.bodyText)",
                                                     attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            descriptionTextView.attributedText = attributedText
            descriptionTextView.textAlignment = .center
        }
    }
    
    private let swipingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        let attributedText = NSMutableAttributedString(string: "", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)])
        attributedText.append(NSAttributedString(string: "", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.gray]))
        
        var attributes = [NSAttributedString.Key: Any]()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 100
        attributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
        attributes[NSAttributedString.Key.font] = UIFont.preferredFont(forTextStyle: .body)
        textView.typingAttributes = attributes
        
        textView.attributedText = attributedText
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textAlignment = .center
        textView.isEditable = false
        textView.isScrollEnabled = false
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    private func setupLayout() {
        let topImageContainerView = UIView()
        
        addSubview(topImageContainerView)
        topImageContainerView.translatesAutoresizingMaskIntoConstraints = false
        topImageContainerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 59).isActive = true
        topImageContainerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
        topImageContainerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
        topImageContainerView.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 1 / 2).isActive = true
        topImageContainerView.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor).isActive = true
        
        topImageContainerView.addSubview(swipingImageView)
        swipingImageView.centerXAnchor.constraint(equalTo: topImageContainerView.centerXAnchor).isActive = true
        swipingImageView.centerYAnchor.constraint(equalTo: topImageContainerView.centerYAnchor).isActive = true
        swipingImageView.heightAnchor.constraint(equalTo: topImageContainerView.heightAnchor).isActive = true
        swipingImageView.widthAnchor.constraint(equalTo: topImageContainerView.widthAnchor).isActive = true
        
        addSubview(descriptionTextView)
        descriptionTextView.topAnchor.constraint(equalTo: topImageContainerView.bottomAnchor).isActive = true
        descriptionTextView.leftAnchor.constraint(equalTo: leftAnchor, constant: 22).isActive = true
        descriptionTextView.rightAnchor.constraint(equalTo: rightAnchor, constant: -22).isActive = true
        descriptionTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
