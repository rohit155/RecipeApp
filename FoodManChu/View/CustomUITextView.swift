//
//  CustomUITextView.swift
//  FoodManChu
//
//  Created by Rohit Jangid on 07/07/21.
//

import UIKit

class CustomUITextView: UITextView {

   
    override func draw(_ rect: CGRect) {
        layer.cornerRadius = 10
        clipsToBounds = true
    }

//    override var textContainerInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
}

extension UITextView {
    func showError() {
        layer.borderWidth = 1
        layer.borderColor = UIColor.red.cgColor
    }
    
    func hideError() {
        layer.borderWidth = 0
        layer.borderColor = nil
    }

}
