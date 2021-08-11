//
//  AlertController.swift
//  FoodManChu
//
//  Created by Rohit Jangid on 09/07/21.
//

import UIKit

class AlertController: UIAlertController {
    
    static let ac = AlertController()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func alertController(vc: UIViewController,title: String?, message: String?, style: UIAlertController.Style ) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: style)
        ac.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        vc.present(ac, animated: true, completion: nil)
//        present(ac, animated: true, completion: nil)
    }
    
}
