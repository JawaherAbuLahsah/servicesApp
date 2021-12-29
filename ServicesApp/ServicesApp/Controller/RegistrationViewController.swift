//
//  RegistrationViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 21/05/1443 AH.
//

import UIKit
import Firebase
class RegistrationViewController: UIViewController {
    
    @IBOutlet weak var userTypeButton: UIButton!{
        didSet{
            userTypeButton.layer.borderWidth = 0.5
            userTypeButton.layer.borderColor = UIColor.systemBlue.cgColor
            userTypeButton.layer.cornerRadius = userTypeButton.frame.size.width / 2.0
            userTypeButton.backgroundColor = .systemBackground
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
    var isProvider = false
    @IBAction func specifyType(_ sender: Any) {
        if isProvider{
            userTypeButton.backgroundColor = .systemBackground
            isProvider = false
        }else{
            userTypeButton.backgroundColor = .systemBlue
            isProvider = true
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    let image = UIImage(systemName: "person.fill")
    @IBAction func handleRegister(_ sender: Any) {
        
        if let name = userNameTaxtField.text ,
           let image = image,
           let imageData = image.jpegData(compressionQuality: 0.25),
           let email = userEmailTextField.text ,
           let phoneNumber = userPhoneNumberTextField.text ,
           let password = passWordTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) { authDataResult, error in
                if let error = error{
                    print(error)
                }
                if let authDataResult = authDataResult {
                    
                    let storageReference = Storage.storage().reference(withPath: "users/\(authDataResult.user.uid)")
                    let uploadMeta = StorageMetadata.init()
                    uploadMeta.contentType = "image/png"
                    storageReference.putData(imageData, metadata: uploadMeta) { storageMeta, error in
                        if let error = error {
                            print("Registration Storage Error",error.localizedDescription)
                        }
                        storageReference.downloadURL { url, error in
                            if let error = error {
                                print("Registration Storage Download Url Error",error.localizedDescription)
                            }
                            if let url = url {
                                print("URL",url.absoluteString)
                                
                                let dataBase = Firestore.firestore()
                                let userData:[String:Any] = [
                                    "id" : authDataResult.user.uid,
                                    "name" : name,
                                    "email" : email,
                                    "phoneNumber" : phoneNumber,
                                    "userType" : self.isProvider,
                                    "profilePictuer": url.absoluteString,
                                    "service":[]
                                ]
                                dataBase.collection("users").document(authDataResult.user.uid).setData(userData){ error in
                                    if let error = error{
                                        print(error)
                                        
                                    }else{
                                        
                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                        if self.isProvider{
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
