//
//  ResetPasswordViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 26/05/1443 AH.
//

import UIKit
import Firebase
class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var resetPasswordView: UIView!{
        didSet{
            resetPasswordView.layer.cornerRadius = 40
//            resetPasswordView.layer.shadowColor = UIColor.black.cgColor
//            resetPasswordView.layer.shadowOpacity = 0.3
//            resetPasswordView.layer.shadowOffset = CGSize.zero
//            resetPasswordView.layer.shadowRadius = 3
           // resetPasswordView.layer.maskedCorners = [.layerMinXMinYCorner]
        }
    }
    @IBOutlet weak var emailLabel: UILabel!{
        didSet{
            emailLabel.text = "email".localizes
        }
    }
    @IBOutlet weak var sendButton: UIButton!{
        didSet{
            sendButton.setTitle("send".localizes, for: .normal)
        }
    }
    @IBOutlet weak var emailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func handleSend(_ sender: Any) {
       let auth = Auth.auth()
        if let email = emailTextField.text{
            auth.sendPasswordReset(withEmail: email) { error in
                if let error = error{
                    print(error)
                }
                
            }
        }
    }

}
