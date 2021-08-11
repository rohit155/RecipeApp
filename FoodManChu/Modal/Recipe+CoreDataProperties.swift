//
//  Recipe+CoreDataProperties.swift
//  FoodManChu
//
//  Created by Rohit Jangid on 30/05/21.
//
//

import Foundation
import CoreData


extension Recipe {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recipe> {
        return NSFetchRequest<Recipe>(entityName: "Recipe")
    }

    @NSManaged public var recipeName: String?
    @NSManaged public var recipeDescription: String?
    @NSManaged public var recipeInstruction: String?
    @NSManaged public var perpTime: Double
    @NSManaged public var ingredient: NSSet?
    @NSManaged public var category: Category?
    @NSManaged public var image: NSSet?

}

// MARK: Generated accessors for ingredient
extension Recipe {

    @objc(addIngredientObject:)
    @NSManaged public func addToIngredient(_ value: Ingredient)

    @objc(removeIngredientObject:)
    @NSManaged public func removeFromIngredient(_ value: Ingredient)

    @objc(addIngredient:)
    @NSManaged public func addToIngredient(_ values: NSSet)

    @objc(removeIngredient:)
    @NSManaged public func removeFromIngredient(_ values: NSSet)

}

// MARK: Generated accessors for image
extension Recipe {

    @objc(addImageObject:)
    @NSManaged public func addToImage(_ value: Image)

    @objc(removeImageObject:)
    @NSManaged public func removeFromImage(_ value: Image)

    @objc(addImage:)
    @NSManaged public func addToImage(_ values: NSSet)

    @objc(removeImage:)
    @NSManaged public func removeFromImage(_ values: NSSet)

}

extension Recipe : Identifiable {

}
