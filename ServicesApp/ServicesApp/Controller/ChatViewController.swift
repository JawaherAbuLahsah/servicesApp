//
//  ChatViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 28/05/1443 AH.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
//import InputBarAccessoryView
import AMKeyboardFrameTracker
class ChatViewController: UIViewController {
    
  //  let inputBar = InputBarAccessoryView()
    @IBOutlet weak var inputViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var endServiceButton: UIButton!{
        didSet{
            endServiceButton.isHidden = true
        }
    }
    
    @IBOutlet weak var chatTextField: UITextField!{
        didSet{
            chatTextField.delegate = self
        }
    }
    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var chatTableView: UITableView!{
        didSet{
            chatTableView.delegate = self
            chatTableView.dataSource = self
        }
    }
    let keyboardFrameTrackerView = AMKeyboardFrameTrackerView.init(height: 60)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared.enable = false
        getData()
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
         self.chatTableView.keyboardDismissMode = .interactive
        
        self.keyboardFrameTrackerView.delegate = self
        self.chatTextField.inputAccessoryView = self.keyboardFrameTrackerView
        //inputBar.chatTextField.keyboardType =
    }
    
    override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            /* you need to set the inputAccessoryView height if you need
             the keyboard to start dismissing exactly when the touch hits the inputContainerView while panning
             if your view interacts with the safeAreas you should be using a height constraint better
             */
            self.keyboardFrameTrackerView.setHeight(self.inputContainerView.frame.height)
        }
    
    
    var messages = [Message]()
    var requestData :[String:Any] = [:]
    var providerId = ""
    var requsterId = ""
    var requsetId = ""
    func saveData(){
        if let chat = chatTextField.text{
            let messageId = "\(Firebase.UUID())"
            let db = Firestore.firestore()
            let currentUser = Auth.auth().currentUser
            if let currentUser = currentUser{
                let message :[String:Any] = [
                    "id" :messageId,
                    "message":chat,
                    "userId": currentUser.uid
                ]
                db.collection("chat").document(currentUser.uid).setData(message){error in
                    if let error = error{
                        print("chat error",error)
                    }
                }
            }
        }
        chatTextField.text = ""
    }
    func getData(){
        let db = Firestore.firestore()
        
        db.collection("requests").whereField("accept", isEqualTo: true).whereField("done", isEqualTo: false).getDocuments { requestsSnapshot, error in
            if let error = error{
                print("chat error",error)
            }
            
            if let requestsSnapshot = requestsSnapshot {
                
                for doc in requestsSnapshot.documents{
                    self.requestData = doc.data()
                    print("llll",self.requestData)
                }
            
                if let requesterUser = self.requestData["requestsId"] as? String,let providerUser = self.requestData["providerId"] as? String{
                    self.providerId = providerUser
                    self.requsterId = requesterUser
                    
                    db.collection("chat").addSnapshotListener { querySnapshot, error in
                        if let error = error{
                            print("chat error",error)
                        }
                        
                        
                        if let querySnapshot = querySnapshot {
                            querySnapshot.documentChanges.forEach { documentChange in
                                if documentChange.type == .removed{
                                    self.messages.removeAll()
                                    self.chatTableView.reloadData()
                                }
                                let message = documentChange.document.data()
                                if let userId = message["userId"] as? String{
                                    db.collection("users").document(userId).getDocument { documentSnapshot, error in
                                        if let error = error{
                                            print("chat error",error)
                                        }
                                        if let documentSnapshot = documentSnapshot,
                                           let userData = documentSnapshot.data(){
                                            let user = User(dict: userData)
                                            
                                            db.collection("chat").document(userId).getDocument { documentSnapshot, error in
                                                if let error = error{
                                                    print("chat error",error)
                                                }
                                                if let documentSnapshot = documentSnapshot, let messageData = documentSnapshot.data(){
                                                    let messageChat = Message(dict: messageData,userId: user)
                                                    if let currentUser = Auth.auth().currentUser{
                                                        if currentUser.uid == providerUser{
                                                            self.endServiceButton.isHidden = false
                                                        }
                                                        
                                                        switch documentChange.type{
                                                        case .added:
                                                            
                                                            self.chatTableView.beginUpdates()
                                                            print(requesterUser ,">>" ,user.id ,">>",providerUser)
                                                            if  currentUser.uid == requesterUser || currentUser.uid == providerUser {
                                                                self.messages.append(messageChat)
                                                                self.chatTableView.insertRows(at: [IndexPath(row:self.messages.count-1,section: 0)],with: .automatic)
                                                            }
                                                            self.chatTableView.endUpdates()
                                                            
                                                        case .modified:
                    
                                                            if  currentUser.uid == requesterUser || currentUser.uid == providerUser {
                                                                self.chatTableView.beginUpdates()
                                                                let newMess = Message(dict: messageData, userId: user)
                                                                
                                                                self.messages.append(newMess)
                                                                self.chatTableView.insertRows(at: [IndexPath(row:self.messages.count-1,section: 0)],with: .automatic)
                                                                
                                                                self.chatTableView.endUpdates()
                                                            }
                                                            
                                                        case .removed:
                                                            self.messages.removeAll()
                                                            self.chatTableView.reloadData()
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
                
            }
        }
    }
    
    
    @IBAction func sendMessage(_ sender: Any) {
        saveData()
    }
    
    @IBAction func endService(_ sender: Any) {
        print("button eeeee")
        if let currentUser = Auth.auth().currentUser{
                    let db = Firestore.firestore()
            db.collection("requests").whereField("providerId", isEqualTo: currentUser.uid).getDocuments { querySnapshot, error in
                if let error = error{
                    print("eeee",error)
                }
                if let querySnapshot = querySnapshot{
                    let document = querySnapshot.documents.first
                    document?.reference.updateData(["done":true])
                }
                
            
            
        
        let chatRef = Firestore.firestore().collection("chat")
                chatRef.document(self.providerId).delete { error in
            if let error = error {
                print("Error in db delete",error)
            }
            
                        chatRef.document(self.requsterId).delete { error in
                            if let error = error {
                                print("Error in db delete",error)
                            }
            
                        }
        }
        
       }
    }
    }
    
}
extension ChatViewController:UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if messages.count == 0 {
            tableView.setEmptyMessage("....")
        }else {
            tableView.restore()
            
        }
        
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatTableViewCell
        cell.messageLabel.text = messages[indexPath.row].message
        if let currentUser = Auth.auth().currentUser{
            if currentUser.uid == messages[indexPath.row].userId.id{
                cell.messageView.backgroundColor = .systemCyan
            }else{
                cell.messageView.backgroundColor = .systemGray6
            }
        }
        cell.selectionStyle = .none
        return cell
    }
    
    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return 100
    //    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}


//extension ChatViewController: InputBarAccessoryViewDelegate {
//  func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
//
//    inputBar.inputTextView.text = ""
//  }
//}


extension ChatViewController: AMKeyboardFrameTrackerDelegate {
    func keyboardFrameDidChange(with frame: CGRect) {
        let tabBarHeight = self.tabBarController?.tabBar.frame.height ?? 0.0
        let bottomSapcing = self.view.frame.height - frame.origin.y - tabBarHeight - self.keyboardFrameTrackerView.frame.height
        
        self.inputViewBottomConstraint.constant = bottomSapcing > 0 ? bottomSapcing : 0
        self.view.layoutIfNeeded()
    }
}
