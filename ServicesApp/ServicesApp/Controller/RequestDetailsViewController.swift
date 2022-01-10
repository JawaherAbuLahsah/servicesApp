//
//  RequestDetailsViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 22/05/1443 AH.
//

import UIKit
import Firebase
class RequestDetailsViewController: UIViewController {
    
    @IBOutlet weak var serviceNameLabel: UILabel!
    var selectServices : Service?
    
    @IBOutlet weak var titleLabel: UILabel!{
        didSet{
            titleLabel.text = "title".localizes
        }
    }
    @IBOutlet weak var detailsLabel: UILabel!{
        didSet{
            detailsLabel.text = "details".localizes
        }
    }
    @IBOutlet weak var sendButton: UIButton!{
        didSet{
            sendButton.setTitle("send".localizes, for: .normal)
        }
    }
    
    @IBOutlet weak var requestTitleTextField: UITextField!{
        didSet{
            requestTitleTextField.delegate = self
        }
    }
    @IBOutlet weak var requestDetailsTextView: UITextView!{
        didSet{
            let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 44.0))
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: #selector(tapDone))
            toolBar.setItems([flexibleSpace, doneButton], animated: false)
            requestDetailsTextView.inputAccessoryView = toolBar
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let selectServices = selectServices{
            serviceNameLabel.text = selectServices.name
        }
        
    }
    
    @IBAction func sendRequest(_ sender: Any) {
        if let title = requestTitleTextField.text,
           let details = requestDetailsTextView.text ,
           let currentUser = Auth.auth().currentUser {
            let requestId = "\(Firebase.UUID())"
            let dataBase = Firestore.firestore()
            if let selectServices = self.selectServices {
                let requestData :[String:Any] = [
                    "requestsId" : currentUser.uid,
                    "providerId" :"0",
                    "title" : title,
                    "details" : details,
                    "price": "0",
                    "createAt" : FieldValue.serverTimestamp(),
                    "haveProvider": false,
                    "serviceId":selectServices.id
                ]
                
                dataBase.collection("requests").document(requestId).setData(requestData){ error in
                    if let error = error {
                        print(error)
                    }
                }
            }
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(identifier: "ServiceRequesterNavigationController")
        mainTabBarController.modalPresentationStyle = .fullScreen
        
        self.present(mainTabBarController, animated: true, completion: nil)
    }
    
    
    @objc func tapDone() {
        self.view.endEditing(true)
    }
    
}

extension RequestDetailsViewController:UITextFieldDelegate,UITextViewDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
}

