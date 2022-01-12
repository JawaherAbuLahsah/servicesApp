//
//  ChatViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 28/05/1443 AH.
//

import UIKit
import Firebase
class ChatViewController: UIViewController {
    
    
    @IBOutlet weak var chatTextField: UITextField!{
        didSet{
            chatTextField.delegate = self
        }
    }
    @IBOutlet weak var chatTableView: UITableView!{
        didSet{
            chatTableView.delegate = self
            chatTableView.dataSource = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
                tap.cancelsTouchesInView = false
                view.addGestureRecognizer(tap)
//        self.tabBarController?.tabBar.isHidden = true
    }
    
    var messages = [Message]()
    
    
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
                db.collection("chat").document(messageId).setData(message){error in
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
        
        db.collection("requests").whereField("accept", isEqualTo: true).getDocuments { requestsSnapshot, error in
            if let error = error{
                print("chat error",error)
            }
            
            if let requestsSnapshot = requestsSnapshot {
                var requestData :[String:Any] = [:]
                for doc in requestsSnapshot.documents{
                    requestData = doc.data()
                    print("llll",requestData)
                }
                
                if let requesterUser = requestData["requestsId"] as? String,let providerUser = requestData["providerId"] as? String{
                  
                    db.collection("chat").addSnapshotListener { querySnapshot, error in
                        if let error = error{
                            print("chat error",error)
                        }
                        
                        
                        if let querySnapshot = querySnapshot {
                            querySnapshot.documentChanges.forEach { documentChange in
                                let message = documentChange.document.data()
                                if let userId = message["userId"] as? String{
                                    db.collection("users").document(userId).getDocument { documentSnapshot, error in
                                        if let error = error{
                                            print("chat error",error)
                                        }
                                        if let documentSnapshot = documentSnapshot,
                                           let userData = documentSnapshot.data(){
                                            let user = User(dict: userData)
                                            if let messageId = message["id"] as? String{
                                                db.collection("chat").document(messageId).getDocument { documentSnapshot, error in
                                                    if let error = error{
                                                        print("chat error",error)
                                                    }
                                                    if let documentSnapshot = documentSnapshot, let messageData = documentSnapshot.data(){
                                                        let messageChat = Message(dict: messageData,userId: user)
                                                        if let currentUser = Auth.auth().currentUser{
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
                                                            
//                                                            let messId = documentChange.document.documentID
//                                                            if let updateIndex = self.messages.firstIndex(where: {$0.id == messId}){
//
//                                                                self.chatTableView.beginUpdates()
//                                                                if user.id == requesterUser || user.id == providerUser {
//                                                                self.chatTableView.insertRows(at: [IndexPath(row: updateIndex, section: 0)], with: .top)
//                                                                }
//                                                                self.chatTableView.endUpdates()
//                                                            }
                                                            break
                                                        case .removed:
                                                            let messId = documentChange.document.documentID
                                                            if let deleteIndex = self.messages.firstIndex(where: {$0.id == messId}){
                                                                self.messages.remove(at: deleteIndex)
                                                                self.chatTableView.beginUpdates()
                                                                self.chatTableView.deleteRows(at: [IndexPath(row: deleteIndex, section: 0)], with: .automatic)
                                                                self.chatTableView.endUpdates()
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
        }
    }
    
    
    @IBAction func sendMessage(_ sender: Any) {
        saveData()
    }
    
    
}
extension ChatViewController:UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
