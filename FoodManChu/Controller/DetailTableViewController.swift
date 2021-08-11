//
//  DetailTableViewController.swift
//  FoodManChu
//
//  Created by Rohit Jangid on 11/07/21.
//

import UIKit

class DetailTableViewController: UITableViewController {

    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var recipeDescriptionLabel: UILabel!
    @IBOutlet weak var recipeInstructionLabel: UILabel!
    @IBOutlet weak var recipeIngredientLabel: UILabel!
    @IBOutlet weak var recipePreparationTimeLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    var recipe: Recipe? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        congigureUI()
//        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
    }
    
    
    //MARK: - Custom functions
    /// Initial configuration for Detail View Controller and to update title
    func congigureUI() {
        if recipe != nil {
            title = "\(recipe?.recipeName ?? "") 😋"
            loadRecipe()
        } else {
            title = "Empty Recipe! 😞"
        }
    }
    
    /// To load recipe in detail screen
    func loadRecipe() {
        guard let image = recipe?.image?.allObjects.first as? Image, let ingredient = recipe?.ingredient?.allObjects as? [Ingredient] else { return }
        recipeImageView.image = image.image as? UIImage
        recipeNameLabel.text = recipe?.recipeName
        recipeDescriptionLabel.text = recipe?.recipeDescription
        recipeInstructionLabel.text = recipe?.recipeInstruction
        recipeIngredientLabel.attributedText = bulletPointList(strings: ingredient.map({ $0.ingredientName ?? "No Ingredient" }).sorted())
        recipePreparationTimeLabel.text = String(recipe?.perpTime ?? 0)
        categoryLabel.text = recipe?.category?.categoryName
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueEditRecipe" {
            if let destinationVC = segue.destination as? CreateRecipeVC {
                destinationVC.updatedRecipeDelegate = self
                destinationVC.recipeToEdit = recipe
                destinationVC.category = recipe?.category
            }
        }
    }
    
    //MARK: - IBAction
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "SegueEditRecipe", sender: nil)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}

//MARK: - UpdatedRecipeDelegate
extension DetailTableViewController: UpdatedRecipeDelegate {
    /// to update recipe
    /// - Parameter recipe: updated recipe
    func getUpdatedRecipe(recipe: Recipe) {
        self.recipe = recipe
        loadRecipe()
        tableView.reloadData()
    }
}
