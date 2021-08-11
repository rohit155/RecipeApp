//
//  CustomUITextField.swift
//  FoodManChu
//
//  Created by Rohit Jangid on 07/07/21.
//

import UIKit

class CustomUITextField: UITextField {

    override func draw(_ rect: CGRect) {
        layer.cornerRadius = 10
        clipsToBounds = true
    }
 
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

}

extension UITextField {
    func showError() {
        layer.borderWidth = 1
        layer.borderColor = UIColor.red.cgColor
    }
    
    func hideError() {
        layer.borderWidth = 0
        layer.borderColor = nil
    }
}
