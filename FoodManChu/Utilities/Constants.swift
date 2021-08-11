//
//  Constants.swift
//  FoodManChu
//
//  Created by Rohit Jangid on 30/05/21.
//

import Foundation
import UIKit

enum Constants {
    static var materalDesign: Bool = false
    static let ad = UIApplication.shared.delegate as! AppDelegate
    static let context = ad.persistentContainer.viewContext
    
    enum Segues {
        static let loadRecipes = "SegueLoadRecipes"
        static let loadIngredientOrCategory = "SegueLoadIngredientOrCategory"
    }
}
