//
//  IngredientAndCategoryTableVC.swift
//  FoodManChu
//
//  Created by Rohit Jangid on 14/06/21.
//

import CoreData
import UIKit

/// Protocol to get selected ingredient and category
protocol AddSelectedIngredient {
    func getSelectedIngredient(_ ingredient: [Ingredient])
    func getSelectedCategory(_ category: Category)
}

class IngredientAndCategoryTableVC: UITableViewController {
    
    @IBOutlet weak var addIngredientBtn: UIBarButtonItem!
    
    var loadIngredient = false
    var ingredientController: NSFetchedResultsController<Ingredient>?
    var category: Category?
    var categories = [Category]()
    var ingredientDelegate: AddSelectedIngredient? = nil
    
    var ingredientSelected = [Ingredient : IndexPath]()

    override func viewDidLoad() {
        super.viewDidLoad()
    
//        generateInitialIngredient()
        configureUI()
    }
    
    /// Initail configuration for Ingredient and Category View Controller
    func configureUI() {
        
        if loadIngredient { //if ture load ingredient else category
            navigationItem.title = "Ingredients"
            addIngredientBtn.isEnabled = true
            fetchIngredient()
            if ingredientController == nil {
                generateInitialIngredient()
                debugPrint("####################  Empty Ingedient  ####################")
            }
        } else {
            navigationItem.title = "Category"
            addIngredientBtn.isEnabled = false
            categories = HomeViewController.categories
        }
    }
    
    //MARK: - IBActions
    /// Method to save user created Ingredients
    /// - Parameter sender: save when ingedient save button is tapped
    @IBAction func addIngredientBtnTapped(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: "Enter Ingredient name", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Save", style: .default) { [unowned ac, unowned self] _ in
            guard let answer = ac.textFields?[0].text, let ingredients = ingredientController?.fetchedObjects else { return }
            
            for item in ingredients {
                if item.ingredientName?.capitalized == answer.capitalized {
                    AlertController.ac.alertController(vc: self, title: "Ingredient already exist", message: "Please enter some different ingredient", style: .alert)
                    return
                }
            }
            
            let newIngredient = Ingredient(context: Constants.context)
            newIngredient.ingredientName = answer.capitalized
            newIngredient.userCreatedIngredient = true
            
            Constants.ad.saveContext()
            
            configureUI()
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        if loadIngredient {
            if let objects = ingredientController?.fetchedObjects {
                return objects.count
            }
            
        }
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientAndCategoryCell") else {
            return UITableViewCell()
        }
        
        if loadIngredient {
            guard let object = ingredientController?.fetchedObjects else { return UITableViewCell() }
            cell.textLabel?.text = object[indexPath.row].ingredientName
            
            //if statement to distinguish betweem user and dafualt ingredient
            if object[indexPath.row].userCreatedIngredient {
                cell.imageView?.image = UIImage(color: UIColor.green, size: CGSize(width: 4, height: 4))
                cell.imageView?.layer.cornerRadius = 5
            } else {
                cell.imageView?.image = UIImage(color: UIColor.orange, size: CGSize(width: 4, height: 4))
                cell.imageView?.layer.cornerRadius = 5
            }
            
            //if statement for checkmark
            if ingredientSelected.keys.contains(object[indexPath.row]) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        } else {
            guard let selectedCategry = category  else { return UITableViewCell() }

            cell.textLabel?.text = categories[indexPath.row].categoryName
            
            if categories[indexPath.row].categoryName == selectedCategry.categoryName {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if loadIngredient {
            guard let ingredient = ingredientController?.fetchedObjects else { return }
            
            if ingredientSelected.values.contains(indexPath) {
                ingredientSelected.removeValue(forKey: ingredient[indexPath.row])
                tableView.reloadRows(at: [indexPath], with: .fade)
            } else {
                ingredientSelected[ingredient[indexPath.row]] = indexPath
                tableView.reloadRows(at: [indexPath], with: .fade)
            }

            ingredientDelegate?.getSelectedIngredient(Array(ingredientSelected.keys))
            
        } else {
            category = categories[indexPath.row]
            ingredientDelegate?.getSelectedCategory(categories[indexPath.row])
            tableView.reloadData()
        }
 
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let ingredient = ingredientController?.fetchedObjects else { return }
        
        if loadIngredient {
            if editingStyle == .delete {
                if ingredient[indexPath.row].userCreatedIngredient {
                    
                    let deleteIngredient = ingredient[indexPath.row]
                    Constants.context.delete(deleteIngredient)
                    
                    if ingredientSelected.keys.contains(deleteIngredient) {
                        ingredientSelected.removeValue(forKey: deleteIngredient)
                        ingredientDelegate?.getSelectedIngredient(Array(ingredientSelected.keys))
                    }

                    Constants.ad.saveContext()
                    configureUI()

                } else {
                    AlertController.ac.alertController(vc: self, title: "Cannot delete Ingredient", message: "You can only delete user created ingredient which is green color", style: .alert)
                }
            }
        }
        
    } // end of tableView commit editingStyle forRowAt method
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if loadIngredient {
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
            
            let label = UILabel()
            
            label.translatesAutoresizingMaskIntoConstraints = false
            
            label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
            label.text = "[Orange] is defualt ingredient and [Green] in user created ingredient"
            //        label.font = .systemFont(ofSize: 16)
            label.font = UIFont(name: "Gill Sans", size: 16)
            label.textColor = .black
            //        label.textAlignment = .center
            label.numberOfLines = 0
            headerView.backgroundColor = .systemYellow
            headerView.layer.cornerRadius = 4
            headerView.addSubview(label)
            
            return headerView
        }
        return nil
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if loadIngredient {
            return 50
        }
        return 0
    }
    

}

//MARK: - Core Data Setup for Ingredient
extension IngredientAndCategoryTableVC: NSFetchedResultsControllerDelegate {
    /// Generating initail approx 50 ingredient for the recipe app
    func generateInitialIngredient() {
        let ingredient1 = Ingredient(context: Constants.context)
            ingredient1.ingredientName = "Salt"
            ingredient1.userCreatedIngredient = false
        
        let ingredient2 = Ingredient(context: Constants.context)
            ingredient2.ingredientName = "Chilli falkes"
            ingredient2.userCreatedIngredient = false
        
        let ingredient3 = Ingredient(context: Constants.context)
            ingredient3.ingredientName = "Black pepper"
            ingredient3.userCreatedIngredient = false
        
        let ingredient4 = Ingredient(context: Constants.context)
            ingredient4.ingredientName = "Coriander"
            ingredient4.userCreatedIngredient = false
        
        let ingredient5 = Ingredient(context: Constants.context)
            ingredient5.ingredientName = "Fennel seeds"
            ingredient5.userCreatedIngredient = false
        
        let ingredient6 = Ingredient(context: Constants.context)
            ingredient6.ingredientName = "Oregano"
            ingredient6.userCreatedIngredient = false
        
        let ingredient7 = Ingredient(context: Constants.context)
            ingredient7.ingredientName = "Turmeric"
            ingredient7.userCreatedIngredient = false
        
        let ingredient8 = Ingredient(context: Constants.context)
            ingredient8.ingredientName = "Whole nutmeg"
            ingredient8.userCreatedIngredient = false
        
        let ingredient9 = Ingredient(context: Constants.context)
            ingredient9.ingredientName = "Bay leaves"
            ingredient9.userCreatedIngredient = false
        
        let ingredient10 = Ingredient(context: Constants.context)
            ingredient10.ingredientName = "Cayenne pepper"
            ingredient10.userCreatedIngredient = false
        
        let ingredient11 = Ingredient(context: Constants.context)
            ingredient11.ingredientName = "Thyme"
            ingredient11.userCreatedIngredient = false
        
        let ingredient12 = Ingredient(context: Constants.context)
            ingredient12.ingredientName = "Cinnamon"
            ingredient12.userCreatedIngredient = false
        
        let ingredient13 = Ingredient(context: Constants.context)
            ingredient13.ingredientName = "Rice"
            ingredient13.userCreatedIngredient = false
        
        let ingredient14 = Ingredient(context: Constants.context)
            ingredient14.ingredientName = "All-purpose flour"
            ingredient14.userCreatedIngredient = false
        
        let ingredient15 = Ingredient(context: Constants.context)
            ingredient15.ingredientName = "White sugarc"
            ingredient15.userCreatedIngredient = false
        
        let ingredient16 = Ingredient(context: Constants.context)
            ingredient16.ingredientName = "Brown sugar"
            ingredient16.userCreatedIngredient = false
        
        let ingredient17 = Ingredient(context: Constants.context)
            ingredient17.ingredientName = "Baking powder"
            ingredient17.userCreatedIngredient = false
        
        let ingredient18 = Ingredient(context: Constants.context)
            ingredient18.ingredientName = "Chicken stock"
            ingredient18.userCreatedIngredient = false
            
        let ingredient19 = Ingredient(context: Constants.context)
            ingredient19.ingredientName = "Beef stock"
            ingredient19.userCreatedIngredient = false
        
        let ingredient20 = Ingredient(context: Constants.context)
            ingredient20.ingredientName = "Milk"
            ingredient20.userCreatedIngredient = false
        
        let ingredient21 = Ingredient(context: Constants.context)
            ingredient21.ingredientName = "Butter"
            ingredient21.userCreatedIngredient = false
        
        let ingredient22 = Ingredient(context: Constants.context)
            ingredient22.ingredientName = "Heavy cream"
            ingredient22.userCreatedIngredient = false
        
        let ingredient23 = Ingredient(context: Constants.context)
            ingredient23.ingredientName = "Eggs"
            ingredient23.userCreatedIngredient = false
        
        let ingredient24 = Ingredient(context: Constants.context)
            ingredient24.ingredientName = "Bacon"
            ingredient24.userCreatedIngredient = false
        
        let ingredient25 = Ingredient(context: Constants.context)
            ingredient25.ingredientName = "Parsley"
            ingredient25.userCreatedIngredient = false
        
        let ingredient26 = Ingredient(context: Constants.context)
            ingredient26.ingredientName = "Carrots"
            ingredient26.userCreatedIngredient = false
        
        let ingredient27 = Ingredient(context: Constants.context)
            ingredient27.ingredientName = "Lemons"
            ingredient27.userCreatedIngredient = false
        
        let ingredient28 = Ingredient(context: Constants.context)
            ingredient28.ingredientName = "Limes"
            ingredient28.userCreatedIngredient = false
        
        let ingredient29 = Ingredient(context: Constants.context)
            ingredient29.ingredientName = "Orange juice"
            ingredient29.userCreatedIngredient = false
        
        let ingredient30 = Ingredient(context: Constants.context)
            ingredient30.ingredientName = "Ketchup"
            ingredient30.userCreatedIngredient = false
        
        let ingredient31 = Ingredient(context: Constants.context)
            ingredient31.ingredientName = "Mayonnaise"
            ingredient31.userCreatedIngredient = false
        
        let ingredient32 = Ingredient(context: Constants.context)
            ingredient32.ingredientName = "vegetable oil"
            ingredient32.userCreatedIngredient = false
        
        let ingredient33 = Ingredient(context: Constants.context)
            ingredient33.ingredientName = "Vinegar"
            ingredient33.userCreatedIngredient = false
        
        let ingredient34 = Ingredient(context: Constants.context)
            ingredient34.ingredientName = "Mustard"
            ingredient34.userCreatedIngredient = false
        
        let ingredient35 = Ingredient(context: Constants.context)
            ingredient35.ingredientName = "Honey"
            ingredient35.userCreatedIngredient = false
        
        let ingredient36 = Ingredient(context: Constants.context)
            ingredient36.ingredientName = "Garlic"
            ingredient36.userCreatedIngredient = false
        
        let ingredient37 = Ingredient(context: Constants.context)
            ingredient37.ingredientName = "Potatoes"
            ingredient37.userCreatedIngredient = false
        
        let ingredient38 = Ingredient(context: Constants.context)
            ingredient38.ingredientName = "Onions"
            ingredient38.userCreatedIngredient = false
        
        let ingredient39 = Ingredient(context: Constants.context)
            ingredient39.ingredientName = "Tomatoes"
            ingredient39.userCreatedIngredient = false
        
        let ingredient40 = Ingredient(context: Constants.context)
            ingredient40.ingredientName = "Beans"
            ingredient40.userCreatedIngredient = false
        
        Constants.ad.saveContext()
        
    }
    
    /// Fetching all the ingredient
    func fetchIngredient() {
        let fetchRequest: NSFetchRequest<Ingredient> = Ingredient.fetchRequest()
        let ingerdientSort = NSSortDescriptor(key: "ingredientName", ascending: true)
        
        fetchRequest.sortDescriptors = [ingerdientSort]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: Constants.context, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        
        do {
            try controller.performFetch()
            self.ingredientController = controller
            tableView.reloadData()
        } catch let error as NSError {
            debugPrint("Failed tp laod Ingredients -> \(error) and \(error.userInfo)")
        }
        
    }
    
}
