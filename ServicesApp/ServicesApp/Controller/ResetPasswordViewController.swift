//
//  ResetPasswordViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 26/05/1443 AH.
//

import UIKit
import Firebase
class ResetPasswordViewController: UIViewController {
    
    // MARK: - Outlat
    @IBOutlet weak var resetPasswordView: UIView!{
        didSet{
            resetPasswordView.layer.cornerRadius = 40
            resetPasswordView.layer.shadowRadius = 30
            resetPasswordView.layer.shadowOpacity = 0.5
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
            sendButton.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var emailTextField: UITextField!
    
    // MARK: - view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view.
    }
    // MARK: - send action
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
