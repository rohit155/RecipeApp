//
//  RecipeViewController.swift
//  FoodManChu
//
//  Created by Rohit Jangid on 09/06/21.
//

import CoreData
import UIKit


class RecipeViewController: UIViewController {

    @IBOutlet weak var recipeFailedLabel: UILabel!
    @IBOutlet weak var recipeTableView: UITableView!
    @IBOutlet weak var createRecipeButton: UIBarButtonItem!
    
    var category: Category?
    var recipeController: NSFetchedResultsController<Recipe>?
    var recipes = [Recipe]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recipeTableView.delegate = self
        recipeTableView.dataSource = self
        
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
   
        loadRecipes()
    }
    
    /// Initail configuration for Recipe View Controller
    func configureUI() {
        
        if recipes.isEmpty {
            recipeTableView.isHidden = true
            recipeFailedLabel.isHidden = false
        } else {
            recipeFailedLabel.isHidden = true
            recipeTableView.isHidden = false
        }
        recipeTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueCreateRecipe" {
            if let destinationVC = segue.destination as? CreateRecipeVC {
                destinationVC.category = category
            }
        } else if segue.identifier == "SegueShowDetail" {
            if let destinationVC = segue.destination as? DetailTableViewController {
                destinationVC.recipe = sender as? Recipe
            }
        } 
    }
    
    
    //MARK: - IBActions
    @IBAction func createRecipeBtnTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "SegueCreateRecipe", sender: nil)
    }
    
}

//MARK: - UITableView Setup
extension RecipeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell") as? RecipeCell else { return UITableViewCell() }
        let recipe = recipes[indexPath.row]
//        print(recipe)
        cell.configCell(recipe)
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recipe = recipes[indexPath.row]
        performSegue(withIdentifier: "SegueShowDetail", sender: recipe)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deleteRecipe = recipes[indexPath.row]
            Constants.context.delete(deleteRecipe)
            Constants.ad.saveContext()
            loadRecipes()
            debugPrint("recipeDeleted :- \(deleteRecipe)")
        }
    }
    
}

//MARK: - Retrieve Recipes
extension RecipeViewController {
    /// fetching recipes with respect to category
    func loadRecipes() {
        let fetchRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        
        let ingerdientSort = NSSortDescriptor(key: "recipeName", ascending: true)
        
        fetchRequest.sortDescriptors = [ingerdientSort]
        fetchRequest.returnsObjectsAsFaults = false
//        fetchRequest.relationshipKeyPathsForPrefetching = ["category", "ingredient", "image"]

        let predicate = NSPredicate(format: "category.categoryName == %@", "\(category?.categoryName ?? "")")
//        let categorySort = NSSortDescriptor(key: "recipeName", ascending: true)
        fetchRequest.predicate = predicate
//        fetchRequest.sortDescriptors = [categorySort]
        
        do {
            if HomeViewController.recipes.isEmpty {
                recipes = try Constants.context.fetch(fetchRequest)
            } else {
                recipes = HomeViewController.recipes
            }
            configureUI()
            
        } catch let error as NSError {
            debugPrint("Failed to load recipes \(error) and \(error.userInfo)")
        }
    }
}
