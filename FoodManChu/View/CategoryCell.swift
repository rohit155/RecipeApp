//
//  CategoryCell.swift
//  FoodManChu
//
//  Created by Rohit Jangid on 30/05/21.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryTitle: UILabel!
    
    func configCell(_ category: Category) {
        categoryTitle.text = category.categoryName
        categoryImage.image = category.image?.image as? UIImage ?? UIImage(named: "placeholderImage")
    }
    
}
