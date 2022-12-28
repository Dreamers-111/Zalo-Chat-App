//
//  CustomInputBarAccessoryView.swift
//  ZaloChatApp
//
//  Created by huy on 13/12/2022.
//
import Foundation
import InputBarAccessoryView
import UIKit

// MARK: - CustomInputBarAccessoryViewDelegate

protocol CustomInputBarAccessoryViewDelegate: InputBarAccessoryViewDelegate {
    func didPressPhotoLibraryBtn()
    func didPressCameraBtn()
    func didPressMicroBtn()
    func didPressMapPinBtn()
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [AttachmentManager.Attachment])
}

extension CustomInputBarAccessoryViewDelegate {
    func inputBar(_: InputBarAccessoryView, didPressSendButtonWith _: [AttachmentManager.Attachment]) {}
    func didPressPhotoLibraryBtn() {}
    func didPresscCameraBtn() {}
    func didPressMicroBtn() {}
    func didPressMapPinBtn() {}
}

// MARK: - CustomInputBarAccessoryView

class CustomInputBarAccessoryView: InputBarAccessoryView {
    private let leftStackViewMaxWidth: CGFloat = 180
    private let leftStackViewMinWidth: CGFloat = 35
    private var isLeftStackViewMinimized = false

    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureInputTextView()
        configureLeftStackView()
        configureSendButton()
        configureAttachmentManager()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    lazy var attachmentManager: AttachmentManager = { [unowned self] in
        let manager = AttachmentManager()
        manager.delegate = self
        return manager
    }()

    // MARK: Methods - UI

    private func configureInputTextView() {
        inputTextView.delegate = self

        let topPadding: CGFloat = 6
        let bottomPadding: CGFloat = 6
        let leftPadding: CGFloat = 8
        let rightPadding: CGFloat = 8

        inputTextView.tintColor = .mainColor
        isTranslucent = true
        separatorLine.isHidden = true
        inputTextView.backgroundColor = UIColor(red: 245 / 255,
                                                green: 245 / 255,
                                                blue: 245 / 255,
                                                alpha: 1)
        inputTextView.placeholderTextColor = UIColor(red: 0.6,
                                                     green: 0.6,
                                                     blue: 0.6,
                                                     alpha: 1)
        inputTextView.textContainerInset = UIEdgeInsets(top: topPadding,
                                                        left: leftPadding,
                                                        bottom: bottomPadding,
                                                        right: rightPadding)
        inputTextView.placeholderLabelInsets = UIEdgeInsets(top: topPadding,
                                                            left: leftPadding + 8,
                                                            bottom: bottomPadding,
                                                            right: rightPadding)
        inputTextView.layer.borderColor = UIColor(red: 200 / 255,
                                                  green: 200 / 255,
                                                  blue: 200 / 255,
                                                  alpha: 1).cgColor
        inputTextView.layer.borderWidth = 1.0
        inputTextView.layer.cornerRadius = 16.0
        inputTextView.layer.masksToBounds = true
        inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: topPadding,
                                                           left: 0,
                                                           bottom: bottomPadding,
                                                           right: 0)

        // add tap gesture for inputTextView
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(didTapInputTextView))
        gesture.delegate = self
        inputTextView.addGestureRecognizer(gesture)
        isUserInteractionEnabled = true
        inputTextView.isUserInteractionEnabled = true
    }

    @objc private func didTapInputTextView() {
        if !isLeftStackViewMinimized {
            minimizeLeftStackView()
        }
    }

    private func configureLeftStackView() {
        isLeftStackViewMinimized = false
        let items = setupLeftInputBarButtonItems()
        setLeftStackViewWidthConstant(to: leftStackViewMaxWidth, animated: false)
        setStackViewItems(items, forStack: .left, animated: false)
    }

    private func configureSendButton() {
        setRightStackViewWidthConstant(to: 35, animated: false)
        sendButton.setSize(CGSize(width: 35, height: 35), animated: false)
        sendButton.title = nil

        // Send button image
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "paperplane.fill")?.withRenderingMode(.alwaysTemplate)
        config.imagePlacement = .all
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .large)
        sendButton.configuration = config

        // This just adds some more flare
        sendButton
            .onEnabled { item in
                UIView.animate(withDuration: 0.2, animations: {
                    item.tintColor = .mainColor
                })
            }.onDisabled { item in
                UIView.animate(withDuration: 0.2, animations: {
                    item.tintColor = .darkGray
                })
            }
    }

    private func configureAttachmentManager() {
        inputPlugins = [attachmentManager]
    }

    // MARK: Methods - Helper

    private func setupLeftInputBarButtonItems() -> [InputBarButtonItem] {
        let camera = makeButton(named: "camera.fill")
        camera.onTouchUpInside { [weak self] _ in
            (self?.delegate as? CustomInputBarAccessoryViewDelegate)?.didPressCameraBtn()
        }
        let mediaLibrary = makeButton(named: "photo.fill")
        mediaLibrary.onTouchUpInside { [weak self] _ in
            (self?.delegate as? CustomInputBarAccessoryViewDelegate)?.didPressPhotoLibraryBtn()
        }

        let micro = makeButton(named: "mic.fill")
        micro.onTouchUpInside { [weak self] _ in
            (self?.delegate as? CustomInputBarAccessoryViewDelegate)?.didPressMicroBtn()
        }

        let mapPin = makeButton(named: "mappin.and.ellipse")
        mapPin.onTouchUpInside { [weak self] _ in
            (self?.delegate as? CustomInputBarAccessoryViewDelegate)?.didPressMapPinBtn()
        }

        return [camera, mediaLibrary, micro, mapPin]
    }

    private func makeButton(named name: String) -> InputBarButtonItem {
        InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                $0.setSize(CGSize(width: 35, height: 35), animated: false)
                $0.image = UIImage(systemName: name)?.withRenderingMode(.alwaysTemplate)
                $0.tintColor = .darkGray
            }.onSelected {
                $0.tintColor = .mainColor
            }.onDeselected {
                $0.tintColor = .darkGray
            }.onTouchUpInside { _ in
                print("Item Tapped")
            }
    }

    private func minimizeLeftStackView() {
        isLeftStackViewMinimized = true
        let maximize = makeButton(named: "chevron.right")
        maximize.onTouchUpInside { [weak self] _ in
            self?.maximizeLeftStackView()
        }
        setLeftStackViewWidthConstant(to: leftStackViewMinWidth, animated: true)
        setStackViewItems([maximize], forStack: .left, animated: true)
    }

    private func maximizeLeftStackView() {
        isLeftStackViewMinimized = false
        let items = setupLeftInputBarButtonItems()
        setLeftStackViewWidthConstant(to: leftStackViewMaxWidth, animated: true)
        setStackViewItems(items, forStack: .left, animated: true)
    }

    // MARK: Methods - Override

    override func didSelectSendButton() {
        if attachmentManager.attachments.count > 0 {
            (delegate as? CustomInputBarAccessoryViewDelegate)?
                .inputBar(self, didPressSendButtonWith: attachmentManager.attachments)
        }
        delegate?.inputBar(self, didPressSendButtonWith: inputTextView.text)
    }
}

// MARK: AttachmentManagerDelegate

extension CustomInputBarAccessoryView: AttachmentManagerDelegate {
    // MARK: - AttachmentManagerDelegate

    func attachmentManager(_: AttachmentManager, shouldBecomeVisible: Bool) {
        setAttachmentManager(active: shouldBecomeVisible)
    }

    func attachmentManager(_ manager: AttachmentManager, didReloadTo _: [AttachmentManager.Attachment]) {
        sendButton.isEnabled = manager.attachments.count > 0
    }

    func attachmentManager(_ manager: AttachmentManager, didInsert _: AttachmentManager.Attachment, at _: Int) {
        sendButton.isEnabled = manager.attachments.count > 0
    }

    func attachmentManager(_ manager: AttachmentManager, didRemove _: AttachmentManager.Attachment, at _: Int) {
        sendButton.isEnabled = manager.attachments.count > 0
    }

    func attachmentManager(_: AttachmentManager, didSelectAddAttachmentAt _: Int) {
        (delegate as? CustomInputBarAccessoryViewDelegate)?.didPressPhotoLibraryBtn()
    }

    // MARK: - AttachmentManagerDelegate Helper

    func setAttachmentManager(active: Bool) {
        let topStackView = topStackView
        if active, !topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
            topStackView.insertArrangedSubview(attachmentManager.attachmentView, at: topStackView.arrangedSubviews.count)
            topStackView.layoutIfNeeded()
        }
        else if !active, topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
            topStackView.removeArrangedSubview(attachmentManager.attachmentView)
            topStackView.layoutIfNeeded()
        }
    }
}

// MARK: UIGestureRecognizerDelegate

extension CustomInputBarAccessoryView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: UITextViewDelegate

extension CustomInputBarAccessoryView: UITextViewDelegate {
    func textViewDidChange(_: UITextView) {
        if !isLeftStackViewMinimized {
            minimizeLeftStackView()
        }
    }
}


