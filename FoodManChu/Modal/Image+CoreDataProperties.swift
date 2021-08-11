//
//  Image+CoreDataProperties.swift
//  FoodManChu
//
//  Created by Rohit Jangid on 30/05/21.
//
//

import Foundation
import CoreData


extension Image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image")
    }

    @NSManaged public var image: NSObject?
    @NSManaged public var recipe: Recipe?
    @NSManaged public var category: Category?

}

extension Image : Identifiable {

}
