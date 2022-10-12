//
//  Extension.swift
//  Messenger
//
//  Created by Phan Tam Nhu on 26/09/2022.
//

import Foundation
import UIKit

extension UITextField {
    func addBottomBorder(){
        var bottomBorder = UIView()
        bottomBorder = UIView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        bottomBorder.backgroundColor = UIColor(red: 0.22, green: 0.82, blue: 0.93, alpha: 1.00)
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomBorder)
        //Setup Anchors
        bottomBorder.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 15).isActive = true
        bottomBorder.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bottomBorder.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bottomBorder.heightAnchor.constraint(equalToConstant: 2).isActive = true // CHiều cao của border
    }
}


extension UIColor {
    static var mainColor = UIColor(red: 0.03, green: 0.45, blue: 1.00, alpha: 1.00)
}

extension UIView {

    public var width: CGFloat {
        return frame.size.width
    }

    public var height: CGFloat {
        return frame.size.height
    }

    public var top: CGFloat {
        return frame.origin.y
    }

    public var bottom: CGFloat {
        return frame.size.height + frame.origin.y
    }

    public var left: CGFloat {
        return frame.origin.x
    }

    public var right: CGFloat {
        return frame.size.width + frame.origin.x
    }

}


