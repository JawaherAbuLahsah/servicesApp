//
//  ResetPasswordViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 26/05/1443 AH.
//

import UIKit
import Firebase
class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
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
