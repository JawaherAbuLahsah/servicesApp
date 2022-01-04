//
//  SMSCodeViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 01/06/1443 AH.
//

import UIKit
import Firebase
class SMSCodeViewController: UIViewController {
    
    @IBOutlet weak var codeLabel: UILabel!{
        didSet{
            
        }
    }
    @IBOutlet weak var sendButton: UIButton!{
        didSet{
            sendButton.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var codeTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func sendCode(_ sender: Any) {
        let db = Firestore.firestore()
        if let currentUser = Auth.auth().currentUser{
            db.collection("users").document(currentUser.uid).getDocument { snapshot, error in
                if let error = error{
                    print(error)
                }
                if let snapshot = snapshot,
                   let userData = snapshot.data(){
                    let user = User(dict: userData)
                    
                    if let code = self.codeTextField.text{
                        
                        AuthManager.shared.verifyCode(smsCode: code) { success in
                            
                            guard success else{return}
                            DispatchQueue.main.async {
                                
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                if user.userType{
                                    let mainTabBarController = storyboard.instantiateViewController(identifier: "ServicesSelectionNavigationController")
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
