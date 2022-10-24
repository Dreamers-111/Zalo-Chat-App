//
//  Extensions.swift
//  Chat-app
//
//  Created by Phạm Văn Nam on 02/10/2022.
//

import Foundation
import UIKit

// border to UItextfield

extension UITextField {
    
    func setFieldLoginAndRegister() {
        translatesAutoresizingMaskIntoConstraints = false
        autocapitalizationType = .none
        autocorrectionType = .no
        returnKeyType = .continue
        clearButtonMode = .whileEditing
        layer.cornerRadius = 15
        backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.00)
        font = .systemFont(ofSize: 16, weight: .medium)
        
        // Thêm padding left cho textfiled
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.size.height))
        leftView = paddingView
        leftViewMode = .always
        heightAnchor.constraint(greaterThanOrEqualToConstant: 55).isActive = true
        
        // màu placeholder
        if let placeholder = placeholder {
            attributedPlaceholder = NSAttributedString(string:placeholder,
                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.40, green: 0.38, blue: 0.38, alpha: 1.00)])
        }
        
        // Shadow Color
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        layer.shadowOpacity = 0.6
        layer.shadowRadius = 1
        layer.masksToBounds = false
    }
}

extension UIColor {
    static var mainColor = UIColor(red: 0.90, green: 0.00, blue: 0.21, alpha: 1.00)
}

extension Date {
    func today(format: String = "dd/MM/yyyy") -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}

// Datepicker in UItextfield
extension UITextField {
    
    func addBottomBorder() {
        let bottomBorder = UIView(frame: .zero)
        bottomBorder.backgroundColor = UIColor(red: 0.22, green: 0.82, blue: 0.93, alpha: 1.00)
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomBorder)
        // Setup Anchors
        bottomBorder.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 15).isActive = true
        bottomBorder.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bottomBorder.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bottomBorder.heightAnchor.constraint(equalToConstant: 2).isActive = true // CHiều cao của border
    }
    
    func datePicker<T>(target: T,
                       doneAction: Selector,
                       cancelAction: Selector,
                       datePickerMode: UIDatePicker.Mode = .date)
    {
        func buttonItem(withSystemItemStyle style: UIBarButtonItem.SystemItem) -> UIBarButtonItem {
            let buttonTarget = style == .flexibleSpace ? nil : target
            let action: Selector? = {
                switch style {
                case .cancel:
                    return cancelAction
                case .done:
                    return doneAction
                default:
                    return nil
                }
            }()

            let barButtonItem = UIBarButtonItem(barButtonSystemItem: style,
                                                target: buttonTarget,
                                                action: action)

            return barButtonItem
        }

        let datePicker = UIDatePicker()

        datePicker.datePickerMode = datePickerMode
        datePicker.preferredDatePickerStyle = .inline

        self.inputView = datePicker

        let toolBar = UIToolbar(frame: CGRect(x: 0,
                                              y: 0,
                                              width: UIScreen.main.bounds.width,
                                              height: 44))

        toolBar.setItems([buttonItem(withSystemItemStyle: .cancel),
                          buttonItem(withSystemItemStyle: .flexibleSpace),
                          buttonItem(withSystemItemStyle: .done)],
                         animated: true)
        self.inputAccessoryView = toolBar
    }
}

// Move view when keyboard appear
extension UIViewController {
    func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotifications(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }

    func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    // This method will notify when keyboard appears/ dissapears
    @objc func keyboardNotifications(notification: NSNotification) {
        var txtFieldY: CGFloat = 0.0 // Using this we will calculate the selected textFields Y Position
        let spaceBetweenTxtFieldAndKeyboard: CGFloat = 5.0 // Specify the space between textfield and keyboard

        var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        if let activeTextField = UIResponder.currentFirst() as? UITextField ?? UIResponder.currentFirst() as? UITextView {
            // Here we will get accurate frame of textField which is selected if there are multiple textfields
            frame = self.view.convert(activeTextField.frame, from: activeTextField.superview)
            txtFieldY = frame.origin.y + frame.size.height
        }

        if let userInfo = notification.userInfo {
            // here we will get frame of keyBoard (i.e. x, y, width, height)
            let keyBoardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let keyBoardFrameY = keyBoardFrame!.origin.y
            let keyBoardFrameHeight = keyBoardFrame!.size.height

            var viewOriginY: CGFloat = 0.0
            // Check keyboards Y position and according to that move view up and down
            if keyBoardFrameY >= UIScreen.main.bounds.size.height {
                viewOriginY = 0.0
            } else {
                // if textfields y is greater than keyboards y then only move View to up
                if txtFieldY >= keyBoardFrameY {
                    viewOriginY = (txtFieldY - keyBoardFrameY) + spaceBetweenTxtFieldAndKeyboard

                    // This condition is just to check viewOriginY should not be greator than keyboard height
                    // if its more than keyboard height then there will be black space on the top of keyboard.
                    if viewOriginY > keyBoardFrameHeight { viewOriginY = keyBoardFrameHeight }
                }
            }

            // set the Y position of view
            self.view.frame.origin.y = -viewOriginY
        }
    }
}

extension UIResponder {
    weak static var responder: UIResponder?

    static func currentFirst() -> UIResponder? {
        self.responder = nil
        UIApplication.shared.sendAction(#selector(trap), to: nil, from: nil, for: nil)
        return self.responder
    }

    @objc private func trap() {
        UIResponder.responder = self
    }
}

extension String {
    var isEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}
