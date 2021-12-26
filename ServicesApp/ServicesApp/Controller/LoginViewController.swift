//
//  LoginViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 21/05/1443 AH.
//

import UIKit
import Firebase
class LoginViewController: UIViewController {
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!{
        didSet{
            emailTextField.delegate = self
        }
    }
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!{
        didSet{
            passwordTextField.delegate = self
        }
    }
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func handleLogin(_ sender: Any) {
        if let email = emailTextField.text,
           let password = passwordTextField.text{
            Auth.auth().signIn(withEmail: email, password: password) { authDataResult, error in
                if let error = error{
                    print(error)
                }
                // add page to go
            }
        }
    }
    
}
extension LoginViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    
        return true
    }
}
