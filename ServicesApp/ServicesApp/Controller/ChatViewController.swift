//
//  ChatViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 28/05/1443 AH.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift

import AMKeyboardFrameTracker
class ChatViewController: UIViewController {
    // MARK: - Outlat
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
    
    @IBOutlet weak var userImage: UIImageView!{
        didSet{
            userImage.layer.borderWidth = 2.0
            userImage.layer.cornerRadius = userImage.bounds.height / 2
            userImage.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var usreNameLabel: UILabel!
    @IBOutlet weak var phonNumberLabel: UILabel!
    
    @IBOutlet weak var userInfoView: UIView!{
        didSet{
            userInfoView.isHidden = true
        }
    }
    
    // MARK: - Definitions
    let keyboardFrameTrackerView = AMKeyboardFrameTrackerView.init(height: 60)
    var messages = [Message]()
    var requestData :[String:Any] = [:]
    var providerId = ""
    var requsterId = ""
    var requsetId = ""
    
    // MARK: - view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared.enable = false
        getData()
        
        self.chatTableView.keyboardDismissMode = .interactive
        
        self.keyboardFrameTrackerView.delegate = self
        self.chatTextField.inputAccessoryView = self.keyboardFrameTrackerView
        
    }
    
    // MARK: - View Did Layout Subviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.keyboardFrameTrackerView.setHeight(self.inputContainerView.frame.height)
    }
    
    
    // MARK: - save data action
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
    
    // MARK: - get data action
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
                        
                        
                        
                        db.collection("users").document(providerUser).getDocument { providerUserDocument, error in
                            if let error = error{
                                print("chat error",error)
                            }
                            if let providerUserDocument = providerUserDocument , let userProvider = providerUserDocument.data() {
                                if let currentUser = Auth.auth().currentUser{
                                    if currentUser.uid == requesterUser{
                                        if let image = userProvider["profilePictuer"] as? String, let name = userProvider["name"] as? String,let phone = userProvider["phoneNumber"] as? String{
                                            self.userImage.lodingImage(image)
                                            self.usreNameLabel.text = name
                                            self.phonNumberLabel.text = phone
                                            self.userInfoView.isHidden = false
                                        }
                                    }
                                }
                                db.collection("users").document(requesterUser).getDocument { requesterUserDocument, error in
                                    if let error = error{
                                        print("chat error",error)
                                    }
                                    if let requesterUserDocument = requesterUserDocument , let userRequester = requesterUserDocument.data() {
                                        if let currentUser = Auth.auth().currentUser{
                                            if currentUser.uid == providerUser{
                                                if let image = userRequester["profilePictuer"]  as? String, let name = userRequester["name"] as? String,let phone = userRequester["phoneNumber"] as? String{
                                                    self.userImage.lodingImage(image)
                                                    self.usreNameLabel.text = name
                                                    self.phonNumberLabel.text = phone
                                                    self.userInfoView.isHidden = false
                                                }
                                            }
                                        }
                                    }
                                }
                            }
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
    
    // MARK: - send ation
    @IBAction func sendMessage(_ sender: Any) {
        saveData()
    }
    // MARK: - end action
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
        userInfoView.isHidden = true
    }
}
// MARK: - Extension
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
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
// MARK: - Extenaion
extension ChatViewController: AMKeyboardFrameTrackerDelegate {
    func keyboardFrameDidChange(with frame: CGRect) {
        let tabBarHeight = self.tabBarController?.tabBar.frame.height ?? 0.0
        let bottomSapcing = self.view.frame.height - frame.origin.y - tabBarHeight - self.keyboardFrameTrackerView.frame.height
        
        self.inputViewBottomConstraint.constant = bottomSapcing > 0 ? bottomSapcing : 0
        self.view.layoutIfNeeded()
    }
}
