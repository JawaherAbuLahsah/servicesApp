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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    var messages = [Message]()
    
    
    func saveData(){
        if let chat = chatTextField.text{
            let messageId = "\(Firebase.UUID())"
            let db = Firestore.firestore()
            let message :[String:Any] = [
                "id" :messageId,
                "message":chat,
            ]
            db.collection("chat").document(messageId).setData(message){error in
                if let error = error{
                    print("chat error",error)
                }
            }
        }
        chatTextField.text = ""
    }
    func getData(){
        let db = Firestore.firestore()
        db.collection("chat").addSnapshotListener { querySnapshot, error in
            if let error = error{
                print("chat error",error)
            }
            if let querySnapshot = querySnapshot{
                querySnapshot.documentChanges.forEach { documentChange in
                    let message = documentChange.document.data()
                    switch documentChange.type{
                    case .added:
                        if let messageId = message["id"] as? String{
                            db.collection("chat").document(messageId).getDocument { documentSnapshot, error in
                                if let error = error{
                                    print("chat error",error)
                                }
                                if let documentSnapshot = documentSnapshot, let messageData = documentSnapshot.data(){
                                    let messageChat = Message(dict: messageData)
                                    
                                    self.chatTableView.beginUpdates()
//                                    self.messages.append(messageChat)
//                                    self.chatTableView.insertRows(at: [IndexPath(row:self.messages.count-1,section: 0)],with: .automatic)
                                    
                                    if querySnapshot.documentChanges.count != 1 {
                                        
                                        self.messages.append(messageChat)
                                        self.chatTableView.insertRows(at: [IndexPath(row:self.messages.count-1,section: 0)],with: .automatic)
                                        
                                    }else {

                                        self.messages.insert(messageChat,at:0)
                                        self.chatTableView.insertRows(at: [IndexPath(row: 0,section: 0)],with: .automatic)
                                        
                                    }
                                    self.chatTableView.endUpdates()
                                }
                            }
                        }
                    case .modified:
                        
                        let messId = documentChange.document.documentID
                         if let updateIndex = self.messages.firstIndex(where: {$0.id == messId}){
                        
                            self.chatTableView.beginUpdates()
                            
                        self.chatTableView.insertRows(at: [IndexPath(row: updateIndex, section: 0)], with: .top)
                            self.chatTableView.endUpdates()
                        }
                            
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
    
    
    

    @IBAction func sendMessage(_ sender: Any) {
        saveData()
    }
    @objc func keyboardWillShow(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= 300
            }
        //}
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

}
extension ChatViewController:UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        content.text = messages[indexPath.row].message
        cell.contentConfiguration = content
        return cell
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
}
