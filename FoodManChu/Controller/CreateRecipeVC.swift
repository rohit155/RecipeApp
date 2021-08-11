//
//  CreateRecipeVC.swift
//  FoodManChu
//
//  Created by Rohit Jangid on 13/06/21.
//

import CoreData
import UIKit

protocol UpdatedRecipeDelegate {
    func getUpdatedRecipe(recipe: Recipe)
}

class CreateRecipeVC: UITableViewController {

    @IBOutlet weak var recipeName: UITextField!
    @IBOutlet weak var recipeDescription: UITextView! {
        didSet {
            recipeDescription.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
    }
    @IBOutlet weak var recipeInstruction: UITextView! {
        didSet {
            recipeInstruction.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
    }
    @IBOutlet weak var preparationTime: UITextField!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var ingredientLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    
    var category: Category?
    var ingredients = [Ingredient]()
    var recipeToEdit: Recipe?
    let indexPathForIngredient = IndexPath(row: 0, section: 3)
    let indexPathForCategory = IndexPath(row: 0, section: 6)
    let indexPathForImage = IndexPath(row: 0, section: 4)
    var updatedRecipeDelegate: UpdatedRecipeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        if recipeToEdit != nil {
            loadExistingData()
        }
    }
    
    /// Initail configuration for Create New Recipe VC
    func configureUI() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        categoryLabel.text = category?.categoryName
        
        recipeName.delegate = self
        recipeDescription.delegate = self
        recipeInstruction.delegate = self
        preparationTime.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        
    }
    
    
    //MARK: - IBActions
    
    /// Function to save new recipe or to update old recipe
    /// - Parameter sender: save button tapped
    @IBAction func saveRecipeTapped(_ sender: UIBarButtonItem) {
        
        if recipeName.text != "" && recipeDescription.text != "" && recipeInstruction.text != "" && preparationTime.text != "" && recipeImageView.image != nil && ingredientLabel.text != "" && categoryLabel.text != "" {
            
            var recipeItem: Recipe!
            let image = Image(context: Constants.context)
            image.image = recipeImageView.image
            
            if recipeToEdit != nil {
                recipeItem = recipeToEdit
            } else {
                recipeItem = Recipe(context: Constants.context)
            }
            
            guard let name = recipeName.text, let description = recipeDescription.text, let instruction = recipeInstruction.text, let time = Double(preparationTime.text!), let recipeCaetgory = category else { return }
            
            recipeItem.recipeName = name
            recipeItem.recipeDescription = description
            recipeItem.recipeInstruction = instruction
            recipeItem.perpTime = time
            recipeItem.ingredient = NSSet(array: ingredients)
            recipeItem.category = recipeCaetgory
            recipeItem.image = NSSet(object: image)
            
            Constants.ad.saveContext()
            
            updatedRecipeDelegate?.getUpdatedRecipe(recipe: recipeItem)
            navigationController?.popViewController(animated: true)
            
        } else {
            
            AlertController.ac.alertController(vc: self, title: "Incomplete details", message: "please enter every fields, Empty fields are not accepted.", style: .alert)
        }
        
        checkForValidTextFields(textField: recipeName)
        checkForValidTextFields(textField: preparationTime)
        
        checkForValidTextView(textView: recipeDescription)
        checkForValidTextView(textView: recipeInstruction)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueLoadIngredientOrCategory" {
            if let destinationVC = segue.destination as? IngredientAndCategoryTableVC {
                guard let loadItemType = sender as? Bool else {
                    debugPrint("Unable to load ingredient or category")
                    return
                }
                destinationVC.ingredientDelegate = self
                destinationVC.loadIngredient = loadItemType
                if loadItemType {
                    if !ingredients.isEmpty {
                        for item in ingredients {
                            destinationVC.ingredientSelected[item] = IndexPath()
                        }
                    }
                } else {
                    destinationVC.category = category
//                    destinationVC.categories = categories
                }
                
            } //end of if let destinationVC
        } //end of if let segue.identifier
    }
    
    
    //MARK: - Custom functions
    
    /// Loading existing recipe if edit button tapped on the previous View controller
    func loadExistingData() {
        if let recipeItem = recipeToEdit, let recipeIngredients = recipeItem.ingredient?.allObjects as? [Ingredient], let image = recipeItem.image?.allObjects.first as? Image {
            
            recipeName.text = recipeItem.recipeName
            recipeDescription.text = recipeItem.recipeDescription
            recipeInstruction.text = recipeItem.recipeInstruction
            ingredientLabel.attributedText = bulletPointList(strings: recipeIngredients.map({ $0.ingredientName ?? "No Ingredient" }).sorted())
            preparationTime.text = String(recipeItem.perpTime)
            categoryLabel.text = recipeItem.category?.categoryName
            recipeImageView.image = image.image as? UIImage
            
            ingredients = recipeIngredients
        }
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case indexPathForIngredient:
            performSegue(withIdentifier: "SegueLoadIngredientOrCategory", sender: Bool(true))
        case indexPathForCategory:
            performSegue(withIdentifier: "SegueLoadIngredientOrCategory", sender: Bool(false))
        case indexPathForImage:
            pickImage()
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == IndexPath(row: 1, section: 4) {
            return 160
        }
        return UITableView.automaticDimension
    }

}

extension CreateRecipeVC: AddSelectedIngredient {
    /// Protocol method to get current recipe
    /// - Parameter category: Current recipe which is selected
    func getSelectedCategory(_ category: Category) {
        self.category = category
        categoryLabel.text = category.categoryName
        
    }
    
    /// List of ingredient selected for the recipe
    /// - Parameter ingredient: list of ingredient of the recipe
    func getSelectedIngredient(_ ingredient: [Ingredient]) {
        ingredients = ingredient
        var list = [String]()
        for item in ingredients {
            list.append(item.ingredientName ?? "")
        }
        ingredientLabel.attributedText = bulletPointList(strings: list.sorted())
        tableView.reloadData()
    }
    
}

//MARK: - UIImagePickerControllerDelegate
extension CreateRecipeVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// Method to select image for recipe
    func pickImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
                
        let alertController = UIAlertController(title: "Choose Image Source", message: nil , preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }
            alertController.addAction(cameraAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            }
            alertController.addAction(photoLibraryAction)
        }

        alertController.addAction(cancelAction)
//        alertController.popoverPresentationController?.sourceView = 
        
        present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        
        recipeImageView.image = selectedImage
        dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - UITextField and UITextView
extension CreateRecipeVC: UITextFieldDelegate, UITextViewDelegate {
    func checkForValidTextFields(textField: UITextField) {
        if textField.text == "" {
            textField.showError()
        } else {
            textField.hideError()
        }
    }
    
    func checkForValidTextView(textView: UITextView) {
        if textView.text == "" {
            textView.showError()
        } else {
            textView.hideError()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }

}
