//
//  ReviewProviderViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 08/06/1443 AH.
//

import UIKit

class ReviewProviderViewController: UIViewController {

    @IBOutlet var starButtonCollection: [UIButton]!
    var rating = 0 {
        didSet{
            for starButton in starButtonCollection{
                let imageName = (starButton.tag < rating ? "star.fill" : "star")
                starButton.setImage(UIImage(systemName: imageName), for: .normal)
                starButton.tintColor = (starButton.tag < rating ? .systemYellow : .darkText)
            }
            print("rating..>>",rating)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func starButtonPressed(_ sender: UIButton) {
        rating = sender.tag + 1
    }
    
}
