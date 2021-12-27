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
                if let authDataResult = authDataResult{
                    let db = Firestore.firestore()
                    db.collection("users").document(authDataResult.user.uid).addSnapshotListener { userSnapshot, error in
                        if let error = error{
                            print(error)
                        }
                        if let userSnapshot = userSnapshot,
                           let userData = userSnapshot.data(){
                            let user = User(dict: userData)
                            print("this is user ",user)
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            if user.userType == "Service Provider"{
                                let mainTabBarController = storyboard.instantiateViewController(identifier: "ServiceProviderNavigationController")
                                mainTabBarController.modalPresentationStyle = .fullScreen
                                
                                self.present(mainTabBarController, animated: true, completion: nil)
                            }
                            if user.userType == "Service Requester"{
                                let mainTabBarController = storyboard.instantiateViewController(identifier: "ServiceRequesterNavigationController")
                                mainTabBarController.modalPresentationStyle = .fullScreen
                                
                                self.present(mainTabBarController, animated: true, completion: nil)
                            }
                        }
                    }
                }
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
