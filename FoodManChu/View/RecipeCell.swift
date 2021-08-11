
//  RecipeCell.swift
//  FoodManChu
//
//  Created by Rohit Jangid on 10/07/21.
//

import UIKit

class RecipeCell: UITableViewCell {

    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var preparationTimeLabel: UILabel! {
        didSet {
            preparationTimeLabel.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var recipeImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configCell(_ recipe: Recipe) {
        guard let image = recipe.image?.allObjects as? [Image] else { return }
        print(recipe)
        recipeNameLabel.text = recipe.recipeName
        preparationTimeLabel.text = " \(recipe.perpTime) 🕐 "
        recipeImageView.image = image.first?.image as? UIImage
    }

}
