//
//  ViewController.swift
//  FoodManChu
//
//  Created by Rohit Jangid on 30/05/21.
//

import CoreData
import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var controller: NSFetchedResultsController<Category>!
    static var categories = [Category]()
    static var recipes: [Recipe] = []
    
    let searchController = UISearchController()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // updating colletion view and generating initail data if empty
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        configureUI()
        attemptFetch()
        if controller == nil {
            generateDummyData()
            debugPrint("####################  Empty category  ####################")
        }
    }
    
    /// Initial configuration for home view controller
    private func configureUI() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search recipes"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueLoadRecipes" {
            if let destinationVC = segue.destination as? RecipeViewController {
                if let category = sender as? Category {
                    destinationVC.category = category
                }
            }
        }
    }
    
}

//MARK: - UISearchControllerDelegate
extension HomeViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    //Updating search result
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchBarText = searchController.searchBar.text else { return }
        if searchBarText != "" {
            fetchRecipes(with: searchBarText)
        }
        
    }

    //presenting recipe view controller when search button tapped
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let searchVC = storyboard.instantiateViewController(identifier: "RecipeVC") as? RecipeViewController else { return }
        
        show(searchVC, sender: self)
    }
    
    //Empty recipe list when cancle button tapped
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        HomeViewController.recipes = []
    }
}

//MARK: - CollectionViewDelegate & UICollectionViewDataSource & UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let sections = controller.sections {
            return sections.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = controller.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as? CategoryCell else {
            return CategoryCell()
        }
        
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.bounds.width * 0.8, height: view.bounds.height * 0.25)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let objs = controller.fetchedObjects, objs.count > 0 {
            let item = objs[indexPath.row]
            performSegue(withIdentifier: "SegueLoadRecipes", sender: item)
        }
    }

    func configureCell(_ cell: CategoryCell, indexPath: IndexPath) {
        let item = controller.object(at: indexPath)
        cell.configCell(item)
    }
    
}

//MARK: - CoreData Setup
extension HomeViewController: NSFetchedResultsControllerDelegate {
    //Search Results for Category, Generating Initial category data
    func generateDummyData() {
        let category1 = Category(context: Constants.context)
        let image1 = Image(context: Constants.context)
        category1.categoryName = "Vegetarian"
        image1.image = UIImage(named: "vegetarian")
        category1.image = image1
        
        let category2 = Category(context: Constants.context)
        let image2 = Image(context: Constants.context)
        category2.categoryName = "Vegan"
        image2.image = UIImage(named: "vegan")
        category2.image = image2
        
        let category3 = Category(context: Constants.context)
        let image3 = Image(context: Constants.context)
        category3.categoryName = "Meat"
        image3.image = UIImage(named: "meat")
        category3.image = image3
        
        let category4 = Category(context: Constants.context)
        let image4 = Image(context: Constants.context)
        category4.categoryName = "Paleo"
        image4.image = UIImage(named: "paleo")
        category4.image = image4
        
        let category5 = Category(context: Constants.context)
        let image5 = Image(context: Constants.context)
        category5.categoryName = "Keto"
        image5.image = UIImage(named: "keto")
        category5.image = image5
        
        Constants.ad.saveContext()

    }
    
    /// Fetching category
    func attemptFetch() {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        let titleSort = NSSortDescriptor(key: "categoryName", ascending: true)

        fetchRequest.sortDescriptors = [titleSort]

        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: Constants.context, sectionNameKeyPath: nil, cacheName: nil)

        controller.delegate = self
        self.controller = controller

        do {
            try controller.performFetch()
            guard let categories = controller.fetchedObjects else {
                debugPrint("Unable to load categories for protocol")
                return
            }
            HomeViewController.categories = categories
        } catch let error as NSError {
            debugPrint("Failed tp laod Categories -> \(error) and \(error.userInfo)")
        }
        
        //To delete category
//        if let result = try? Constants.context.fetch(fetchRequest) {
//            for object in result {
//                Constants.context.delete(object)
//            }
//        }
//        Constants.ad.saveContext()
//        collectionView.reloadData()
        
    }
    
    //search results for recipes
    
    /// fetching recipes with filer
    /// - Parameter str: string (recipe) to filter the recipe search
    func fetchRecipes(with str: String) {
        let fetchRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        
        let ingredientSort = NSSortDescriptor(key: "recipeName", ascending: true)

        fetchRequest.sortDescriptors = [ingredientSort]
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.relationshipKeyPathsForPrefetching = ["category", "ingredient", "image"]

        let predicate = NSPredicate(format: "recipeName CONTAINS[c] %@ OR ingredient.ingredientName CONTAINS[c] %@ OR recipeDescription CONTAINS[c] %@ OR perpTime CONTAINS[c] %@ OR category.categoryName CONTAINS[c] %@", str, str, str, str, str)

        fetchRequest.predicate = predicate
        
        do {
            HomeViewController.recipes = try Constants.context.fetch(fetchRequest)

        } catch let error as NSError {
            debugPrint("Failed to load recipes \(error) and \(error.userInfo)")
        }
    }
    
}
