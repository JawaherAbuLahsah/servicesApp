//
//  UserRequestsViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 22/05/1443 AH.
//


//It remains to make the request go to more than one service provider

import UIKit
import Firebase
class UserRequestsViewController: UIViewController {
    
    
    @IBOutlet weak var requestsTableView: UITableView!{
        didSet{
            requestsTableView.delegate = self
            requestsTableView.dataSource = self
        }
    }
    var userRequests = [Request]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
    }
    
    
    func getData(){
        let db = Firestore.firestore()
        db.collection("requests").addSnapshotListener { snapshot, error in
            if let error = error{
                print("ERROR in get requests data in userReuqests ",error)
            }
            if let snapshot = snapshot{
                snapshot.documentChanges.forEach { documentChange in
                    let requestData = documentChange.document.data()
                    
                    
                    if let currentUser = Auth.auth().currentUser{
                        db.collection("users").document(currentUser.uid).getDocument { userProviderSnapshot, error in
                            if let error = error{
                                print("Error in get provider data ",error)
                            }
                            if let userId = requestData["requestsId"] as? String{
                                
                                db.collection("users").document(userId).getDocument { userSnapshot, error in
                                    if let error = error{
                                        print("3",error)
                                    }
                                    
                                    switch documentChange.type{
                                    case .added:
                                        
                                        if let userProviderSnapshot = userProviderSnapshot,
                                           let userProviderData = userProviderSnapshot.data(),
                                           let userSnapshot = userSnapshot,
                                           let userData = userSnapshot.data(){
                                            let user = User(dict: userData)
                                            let userProvider = User(dict: userProviderData)
                                            print(user)
                                            print(userProvider)
                                            
                                            let request = Request(dict: requestData,id: documentChange.document.documentID,userRequest: user ,userProvider: userProvider)
                                            
                                            if !request.haveProvider {
                                                self.userRequests.append(request)
                                                self.requestsTableView.reloadData()
                                                print(self.userRequests)
                                            }
                                        }
                                        
                                    case .modified:
                                        let requestId = documentChange.document.documentID
                                        if let updateIndex = self.userRequests.firstIndex(where: {$0.id == requestId}){
                                            
                                            self.requestsTableView.beginUpdates()
                                            self.userRequests.remove(at: updateIndex)
                                            self.requestsTableView.deleteRows(at: [IndexPath(row: updateIndex, section: 0)], with: .left)
                                            self.requestsTableView.endUpdates()
                                            
                                            
                                        }
                                    case .removed:
                                        let requestId = documentChange.document.documentID
                                        if let deleteIndex = self.userRequests.firstIndex(where: {$0.id == requestId}){
                                            self.userRequests.remove(at: deleteIndex)
                                            self.requestsTableView.beginUpdates()
                                            self.requestsTableView.deleteRows(at: [IndexPath(row: deleteIndex, section: 0)], with: .automatic)
                                            self.requestsTableView.endUpdates()
                                            
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

extension UserRequestsViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "requestCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        content.text = userRequests[indexPath.row].title
        
        cell.accessoryType = .detailButton
        
        cell.contentConfiguration = content
        return cell
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: userRequests[indexPath.row].title, message: "\(userRequests[indexPath.row].details) \n \(userRequests[indexPath.row].userRequest.name)", preferredStyle: .alert)
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = "add price"
            textField.keyboardType = .decimalPad
            let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 44.0))
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let DoneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.tapDone))
            toolBar.setItems([flexibleSpace, DoneButton], animated: false)
            textField.inputAccessoryView = toolBar
        }
        
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel) { Action in
            
        }
        let sendAction = UIAlertAction(title: "send", style: .default) { Action in
            
            if let fields = alert.textFields{
                let price = fields[0]
                if let price = price.text, !price.isEmpty{
                    
                    let db = Firestore.firestore()
                    let ref = db.collection("requests")
                    
                    let priceData:[String:Any]
                    if self.userRequests[indexPath.row].userProvider.id != Auth.auth().currentUser?.uid{
                        priceData = ["price": price,
                                     "requestsId" : self.userRequests[indexPath.row].userRequest.id,
                                     "providerId":self.userRequests[indexPath.row].userProvider.id,
                                     "title" : self.userRequests[indexPath.row].title ,
                                     "details" : self.userRequests[indexPath.row].details ,
                                     "createAt" : FieldValue.serverTimestamp(),
                                     "haveProvider":true
                        ]
                    }else{
                        priceData = ["price": price,
                                     "requestsId" : self.userRequests[indexPath.row].userRequest.id,
                                     "providerId":self.userRequests[indexPath.row].userProvider.id,
                                     "title" : self.userRequests[indexPath.row].title ,
                                     "details" : self.userRequests[indexPath.row].details ,
                                     "createAt" : FieldValue.serverTimestamp(),
                                     "haveProvider":true
                        ]
                        
                    }
                    
                    ref.document(self.userRequests[indexPath.row].id).setData(priceData) { error in
                        if let error = error {
                            print("FireStore Error",error.localizedDescription)
                        }
                    }
                }else{
                    print("oh no")
                }
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(sendAction)
        self.present(alert, animated: true, completion: nil)
    }
    @objc func tapDone() {
        self.view.endEditing(true)
    }
}
