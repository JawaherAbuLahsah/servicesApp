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
                            if let userId = requestData["requestsId"] as? String,
                               let serviceId = requestData["serviceId"] as? String{
                                
                                db.collection("users").document(userId).getDocument { userSnapshot, error in
                                    if let error = error{
                                        print("3",error)
                                    }
                                    db.collection("services").document(serviceId).getDocument { serviceSnapshot, error in
                                        if let error = error{
                                            print("3",error)
                                        }
                                        if let userProviderSnapshot = userProviderSnapshot,
                                           let userProviderData = userProviderSnapshot.data(),
                                           let serviceSnapshot = serviceSnapshot,
                                           let serviceData = serviceSnapshot.data(),
                                           let userSnapshot = userSnapshot,
                                           let userData = userSnapshot.data(){
                                            let user = User(dict: userData)
                                            let userProvider = User(dict: userProviderData)
                                            let service = Service(dict: serviceData)
                                            print(user)
                                            print(userProvider)
                                            
                                            let request = Request(dict: requestData,id: documentChange.document.documentID,userRequest: user ,userProvider: userProvider, requestType: service)
                                            switch documentChange.type{
                                            case .added:
                                              
                                                if !request.haveProvider {
                                                    
                                                    for id in userProvider.service{
                                                        if id == service.id{
                                                            let loc = userProvider.location.distance(from: request.location) / 1000
                                                            if loc < 30{
                                                            self.userRequests.append(request)
                                                            }
                                                        }
                                                    }
                                                    self.requestsTableView.reloadData()
                                                    print(self.userRequests)
                                                }
                                                
                                                
                                            case .modified:
                                                let requestId = documentChange.document.documentID
                                                
                                                let newRequest = Request(dict: requestData, id: requestId, userRequest: user, userProvider: userProvider, requestType: service)
                                                print(newRequest)
                                                
                                                if newRequest.title != "" && !newRequest.haveProvider{
                                                    self.requestsTableView.beginUpdates()
                                                    self.userRequests.append(newRequest)
                                                    self.requestsTableView.insertRows(at: [IndexPath(row:self.userRequests.count - 1,section: 0)],with: .automatic)
                                                    self.requestsTableView.endUpdates()
                                                }
                                                
                                                if newRequest.haveProvider{
                                                    if let deleteIndex = self.userRequests.firstIndex(where: {$0.id == requestId}){
                                                        self.userRequests.remove(at: deleteIndex)
                                                        self.requestsTableView.beginUpdates()
                                                        self.requestsTableView.deleteRows(at: [IndexPath(row: deleteIndex, section: 0)], with: .automatic)
                                                        self.requestsTableView.endUpdates()
                                                    }
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
    }
}

extension UserRequestsViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if userRequests.count == 0 {
            tableView.setEmptyMessage("noRequest".localizes)
        }else {
            tableView.restore()
            
        }
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
            textField.placeholder = "price".localizes
            textField.keyboardType = .decimalPad
            let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 44.0))
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let DoneButton = UIBarButtonItem(title: "done".localizes, style: .plain, target: self, action: #selector(self.tapDone))
            toolBar.setItems([flexibleSpace, DoneButton], animated: false)
            textField.inputAccessoryView = toolBar
        }
        
        let cancelAction = UIAlertAction(title: "cancel".localizes, style: .cancel) { Action in
            
        }
        let sendAction = UIAlertAction(title: "send".localizes, style: .default) { Action in
            
            if let fields = alert.textFields{
                let price = fields[0]
                if let price = price.text, !price.isEmpty{
                    
                    let db = Firestore.firestore()
                    let ref = db.collection("requests")
                    
                    let priceData:[String:Any] = ["price": price,
                                                  "requestsId" : self.userRequests[indexPath.row].userRequest.id,
                                                  "providerId":self.userRequests[indexPath.row].userProvider.id,
                                                  "title" : self.userRequests[indexPath.row].title ,
                                                  "details" : self.userRequests[indexPath.row].details ,
                                                  "createAt" : FieldValue.serverTimestamp(),
                                                  "haveProvider":true,
                                                  "serviceId":self.userRequests[indexPath.row].requestType.id,
                                                  "latitude" : self.userRequests[indexPath.row].latitude,
                                                  "longitude" : self.userRequests[indexPath.row].longitude
                    ]
                    
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
