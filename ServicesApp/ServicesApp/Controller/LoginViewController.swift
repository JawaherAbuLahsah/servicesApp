//
//  LoginViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 21/05/1443 AH.
//

import UIKit
import Firebase
import MaterialComponents

class LoginViewController: UIViewController {
    
    // MARK: - Outlet
    @IBOutlet weak var showPasswordButton: UIButton!
    @IBOutlet weak var loginView: UIView!{
        didSet{
            loginView.layer.cornerRadius = 40
            loginView.layer.shadowRadius = 30
            loginView.layer.shadowOpacity = 0.5
        }
    }
//    @IBOutlet weak var emailLabel: UILabel!{
//        didSet{
//            emailLabel.text = "email".localizes
//        }
//    }
    @IBOutlet weak var emailTextField: MDCOutlinedTextField!{
        didSet{
            emailTextField.label.text = "email".localizes
            emailTextField.delegate = self
        }
    }
//    @IBOutlet weak var emailTextField: UITextField!{
//        didSet{
//            emailTextField.delegate = self
//        }
//    }
//    @IBOutlet weak var passwordLabel: UILabel!{
//        didSet{
//            passwordLabel.text = "password".localizes
//        }
//    }
    @IBOutlet weak var passwordTextField: MDCOutlinedTextField!{
        didSet{
            passwordTextField.delegate = self
            passwordTextField.isSecureTextEntry = true
            passwordTextField.label.text = "password".localizes
        }
    }
    @IBOutlet weak var loginButton: UIButton!{
        didSet{
            loginButton.setTitle("login".localizes, for: .normal)
            loginButton.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var signUpButton: UIButton!{
        didSet{
            signUpButton.setTitle("signup".localizes, for: .normal)
            signUpButton.layer.cornerRadius = 10
        }
    }
    
    @IBOutlet weak var forgotPasswordButton: UIButton!{
        didSet{
            forgotPasswordButton.setTitle("forgot".localizes, for: .normal)
        }
    }
    
    // MARK: - variables
    var activityIndicator = UIActivityIndicatorView()
    var isShowPassword = true
    
    // MARK: - view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        //dismiss the keyboard when pressing outside
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        // to make the button inside the textfield
        passwordTextField.trailingView = showPasswordButton
        passwordTextField.trailingViewMode = .whileEditing
        //passwordTextField.rightView = showPasswordButton
       // passwordTextField.rightViewMode = .whileEditing
        
        
    }
    // MARK: - Show password action
    @IBAction func showPassword(_ sender: UIButton) {
        if isShowPassword {
            // show password
            passwordTextField.isSecureTextEntry = false
            
            showPasswordButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            isShowPassword = false
        }else{
            // hide password
            passwordTextField.isSecureTextEntry = true
            showPasswordButton.setImage(UIImage(systemName: "eye"), for: .normal)
            isShowPassword = true
        }
    }
    
    // MARK: - Login action
    @IBAction func handleLogin(_ sender: Any) {
        if let email = emailTextField.text,
           let password = passwordTextField.text{
            Activity.showIndicator(parentView: self.view, childView: activityIndicator)
            Auth.auth().signIn(withEmail: email, password: password) { authDataResult, error in
                if let _ = error{
                    Alert.showAlertError("check".localizes)
                    self.present(Alert.alert, animated: true, completion: nil)
                    Activity.removeIndicator(parentView: self.view, childView: self.activityIndicator)
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
                            
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            Activity.removeIndicator(parentView: self.view, childView: self.activityIndicator)
                            if authDataResult.user.email == "j@j.com"{
                                let mainTabBarController = storyboard.instantiateViewController(identifier: "AdminNavigationController")
                                mainTabBarController.modalPresentationStyle = .fullScreen
                                
                                self.present(mainTabBarController, animated: true, completion: nil)
                            }else{
                                if user.userType {
                                    let mainTabBarController = storyboard.instantiateViewController(identifier: "ServiceProviderNavigationController")
                                    mainTabBarController.modalPresentationStyle = .fullScreen
                                    
                                    self.present(mainTabBarController, animated: true, completion: nil)
                                }else{
                                    let mainTabBarController = storyboard.instantiateViewController(identifier: "ServiceRequesterNavigationController")
                                    mainTabBarController.modalPresentationStyle = .fullScreen
                                    
                                    self.present(mainTabBarController, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
            }
        }else{
            
            Alert.showAlertError("check".localizes)
            self.present(Alert.alert, animated: true, completion: nil)
            Activity.removeIndicator(parentView: self.view, childView: self.activityIndicator)
        }
    }
    
}
// MARK: - Extension
extension LoginViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
