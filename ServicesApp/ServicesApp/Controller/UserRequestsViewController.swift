//
//  UserRequestsViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 22/05/1443 AH.
//




// this view controller I need to work on because I have two types of user <<<<don't forget>>>>>>


import UIKit
import Firebase
class UserRequestsViewController: UIViewController {
    var rId = ""
    var usId = ""
    @IBOutlet weak var requestsTableView: UITableView!{
        didSet{
            requestsTableView.delegate = self
            requestsTableView.dataSource = self
        }
    }
    var userRequests = [Request]()
    var selectedRequests : Request?
    var provider : User?
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        getProviderData()
    }
    func getData(){
        let db = Firestore.firestore()
        db.collection("requests").order(by: "createAt",descending: true).addSnapshotListener { snapshot, error in
            
            if let error = error{
                print(error)
            }
            if let snapshot = snapshot{
                snapshot.documentChanges.forEach { documentChange in
                    let requestData = documentChange.document.data()
                    self.rId = documentChange.document.documentID
                    switch documentChange.type{
                    case .added:
                        if let userId = requestData["userId"] as? String{
                            self.usId = userId
                            db.collection("users").document(userId).getDocument { userSnapshot, error in
                                if let error = error{
                                    print(error)
                                }
                                if let userSnapshot = userSnapshot,
                                   let userData = userSnapshot.data(){
                                    let user = User(dict: userData)
                                    let request = Request(dict: requestData,id: documentChange.document.documentID)
                                    print("whyyyy",userData)
                                    print("whyyyy",user)
                                    self.userRequests.append(request)
                                    self.requestsTableView.reloadData()
                                    print(self.userRequests)
                                }
                            }
                            
                        }
                    case .modified:
                        let requestId = documentChange.document.documentID
                        if let currentRequest = self.userRequests.first(where: {$0.id == requestId}),
                           let updateIndex = self.userRequests.firstIndex(where: {$0.id == requestId}){
                            let newRequest =  Request(dict: requestData,id: requestId)
                            self.userRequests[updateIndex] = newRequest
                            
                            
                            self.requestsTableView.beginUpdates()
                            self.requestsTableView.deleteRows(at: [IndexPath(row: updateIndex, section: 0)], with: .left)
                            self.requestsTableView.insertRows(at: [IndexPath(row: updateIndex, section: 0)], with: .left)
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
    
    func getProviderData(){
        if let currentUser = Auth.auth().currentUser?.uid{
            let db = Firestore.firestore()
            db.collection("user").document(currentUser).addSnapshotListener { snapshot, error in
                
                if let error = error{
                    print(error)
                }
                if let snapshot = snapshot{
                    
                    if let userData = snapshot.data(){
                        let user = User(dict: userData)
                        // if user.userType == "Service Provider"{
                        self.provider = user
                        // }
                    }
                    
                }
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let sender = segue.destination as! ServiceProvidersViewController
        sender.selectedRequests = selectedRequests
        if let provider = provider{
            sender.serviceProviders = [provider]
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
        cell.contentConfiguration = content
        cell.accessoryType = .detailButton
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: userRequests[indexPath.row].title, message: "\(userRequests[indexPath.row].details)", preferredStyle: .alert)
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
            //remove from table
        }
        let sendAction = UIAlertAction(title: "send", style: .default) { Action in
            //change Price
            if let fields = alert.textFields{
                let price = fields[0]
                if let price = price.text, !price.isEmpty{
                    print(price)
                    // self.performSegue(withIdentifier: "toServiceProvidersVC", sender: self)
                     let db = Firestore.firestore()
                     let ref = db.collection("requests")
                     
                         let priceData:[String:Any] = ["price": price,
                                                       "userId" : self.usId,
                                                   "title" : self.userRequests[indexPath.row].title ,
                                                   "details" : self.userRequests[indexPath.row].details ,
                                                   "createAt" : FieldValue.serverTimestamp()
                     ]
                     ref.document(self.rId).setData(priceData) { error in
                         if let error = error {
                             print("FireStore Error",error.localizedDescription)
                     }
                     }
                }else{
                    print("oh no")
                }
            }
            self.selectedRequests = self.userRequests[indexPath.row]
           // self.performSegue(withIdentifier: "toServiceProvidersVC", sender: self)
//            let db = Firestore.firestore()
//            let ref = db.collection("requests")
//            if let selectedRequests = self.selectedRequests{
//                let priceData:[String:Any] = ["price": self.price,
//                                          "userId" : selectedRequests.id ,
//                                          "title" : self.userRequests[indexPath.row].title ,
//                                          "details" : self.userRequests[indexPath.row].details ,
//                                          "createAt" : FieldValue.serverTimestamp()
//            ]
//            ref.document(self.rId).setData(priceData) { error in
//                if let error = error {
//                    print("FireStore Error",error.localizedDescription)
//                }
//
//            }
//            }
        }
        alert.addAction(cancelAction)
        alert.addAction(sendAction)
        self.present(alert, animated: true, completion: nil)
    }
    @objc func tapDone() {
        self.view.endEditing(true)
    }
}
