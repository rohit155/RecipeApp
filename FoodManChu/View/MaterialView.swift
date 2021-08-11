//
//  MaterialDesign.swift
//  FoodManChu
//
//  Created by Rohit Jangid on 30/05/21.
//

import Foundation
import UIKit

extension UIView {
    @IBInspectable var materialDesign: Bool {
        get {
            return Constants.materalDesign
        }
        
        set {
            Constants.materalDesign = newValue
            
            if Constants.materalDesign {
//                layer.masksToBounds = false
                layer.cornerRadius = 4
                layer.shadowOpacity = 0.8
                layer.shadowRadius = 4
                layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
                layer.shadowColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
            } else {
                layer.cornerRadius = 0
                layer.shadowOpacity = 0
                layer.shadowRadius = 0
                layer.shadowColor = nil
            }
        }
    }
    
}
