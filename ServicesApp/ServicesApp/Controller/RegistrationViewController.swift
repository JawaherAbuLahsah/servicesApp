//
//  RegistrationViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 21/05/1443 AH.
//

import UIKit
import Firebase
class RegistrationViewController: UIViewController {
    var userType = ""
    @IBOutlet weak var userTypeSegmentedControl: UISegmentedControl!{
        didSet{
            if userTypeSegmentedControl.selectedSegmentIndex == 0 {
                userType = "Service Provider"
            }else{
                userType = "Service Requester"
            }
        }
    }
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userNameTaxtField: UITextField!{
        didSet{
            userNameTaxtField.delegate = self
        }
    }
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var userEmailTextField: UITextField!{
        didSet{
            userEmailTextField.delegate = self
        }
    }
    @IBOutlet weak var userPhoneNumberLabel: UILabel!
    @IBOutlet weak var userPhoneNumberTextField: UITextField!{
        didSet{
            userPhoneNumberTextField.delegate = self
        }
    }
    @IBOutlet weak var passWordLabel: UILabel!
    @IBOutlet weak var passWordTextField: UITextField!{
        didSet{
            passWordTextField.delegate = self
        }
    }
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func handleRegister(_ sender: Any) {
        if let name = userNameTaxtField.text ,
           let email = userEmailTextField.text ,
           let phoneNumber = userPhoneNumberTextField.text ,
           let password = passWordTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) { authDataResult, error in
                if let error = error{
                    print(error)
                }
                if let authDataResult = authDataResult {
                    let dataBase = Firestore.firestore()
                    let userData:[String:String] = [
                        "id" : authDataResult.user.uid,
                        "name" : name,
                        "email" : email,
                        "phoneNumber" : phoneNumber,
                        "userType" : self.userType
                    ]
                    dataBase.collection("users").document(authDataResult.user.uid).setData(userData){ error in
                        if let error = error{
                            print(error)
                            
                        }else{
                            
                            if self.userTypeSegmentedControl.selectedSegmentIndex == 0 {
                                print(">>>>>",self.userTypeSegmentedControl.selectedSegmentIndex)
                                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ServiceProviderNavigationController") as?  UIViewController {
                                    vc.modalPresentationStyle = .fullScreen
                                }
                                }else{
                                    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ServiceRequesterNavigationController") as? UINavigationController {
                                        vc.modalPresentationStyle = .fullScreen
                                    }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }


extension RegistrationViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
