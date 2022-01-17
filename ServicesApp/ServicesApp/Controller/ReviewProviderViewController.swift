//
//  ReviewProviderViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 08/06/1443 AH.
//

import UIKit
import Firebase
class ReviewProviderViewController: UIViewController {
    
    // MARK: - Outlat
    @IBOutlet weak var reviewView: UIView!{
        didSet{
            reviewView.layer.cornerRadius = 10
            reviewView.layer.shadowRadius = 30
            reviewView.layer.shadowOpacity = 0.5
        }
    }
    @IBOutlet weak var saveButton: UIButton!{
        didSet{
            saveButton.setTitle("send".localizes, for: .normal)
            saveButton.layer.cornerRadius = 10
        }
    }
    @IBOutlet var starButtonCollection: [UIButton]!
    // MARK: - Definitions
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
    var selectUser : User?
    var id = ""
    // MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    // MARK: - action star
    @IBAction func starButtonPressed(_ sender: UIButton) {
        rating = sender.tag + 1
    }
    
    // MARK: - save action
    @IBAction func saveRating(_ sender: Any) {
        if let selectUser = selectUser {
            
            let sum = rating + selectUser.numberStar
            let avg = sum/selectUser.numberRating
            print("rating..>>",avg)
            
            let db = Firestore.firestore()
            db.collection("users").document(selectUser.id).updateData(["numberRating":selectUser.numberRating+1])
            db.collection("users").document(selectUser.id).updateData(["numberStar":sum])
            db.collection("users").document(selectUser.id).updateData(["rating":Double(avg)])
            let ref = Firestore.firestore().collection("requests")
            ref.document(id).delete { error in
                if let error = error {
                    print("Error in db delete",error)
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
}
