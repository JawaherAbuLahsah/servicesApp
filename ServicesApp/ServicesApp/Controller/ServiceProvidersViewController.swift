//
//  ServiceProvidersViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 22/05/1443 AH.
//

import UIKit
import Firebase
class ServiceProvidersViewController: UIViewController {
    
    @IBOutlet weak var serviceProvidersTableView: UITableView!{
        didSet{
            serviceProvidersTableView.delegate = self
            serviceProvidersTableView.dataSource = self
        }
    }
    
    var selectUser : User?
    var serviceProviders = [Request]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getData()
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
                tap.cancelsTouchesInView = false
                view.addGestureRecognizer(tap)
    }
    
    
    
    func getData(){
        let db = Firestore.firestore()
        db.collection("requests").order(by: "createAt",descending: true).addSnapshotListener { snapshot, error in
            
            if let error = error{
                print("5",error)
            }
            if let snapshot = snapshot{
                
                snapshot.documentChanges.forEach { documentChange in
                    let requestData = documentChange.document.data()
                    
                    if let userId = requestData["requestsId"] as? String, let providerId = requestData["providerId"] as? String ,let serviceId = requestData["serviceId"] as? String{
                        
                        db.collection("users").document(userId).getDocument { userSnapshot, error in
                            if let error = error{
                                print("6",error)
                            }
                            db.collection("users").document(providerId).getDocument { userProviderSnapshot, error in
                                if let error = error{
                                    print("Error in get provider data ",error)
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
                                        print("provider>>,",userProvider)
                                        print("Requesterr>>",user)
                                        
                                        print("test location ",user.location,">>",user.location.distance(from: request.location) / 1000)
                                        
                                        
                                        switch documentChange.type{
                                        case .added:
                                            let currentUser = Auth.auth().currentUser
                                            if let currentUser = currentUser, currentUser.uid ==  user.id, request.haveProvider,!request.accept{
                                                self.serviceProviders.append(request)
                                                self.serviceProvidersTableView.reloadData()
                                                print(self.serviceProviders)
                                                print("myyy",request,"vvv",self.serviceProviders)
                                            }
                                            if let currentUser = currentUser, currentUser.uid ==  user.id, request.done == true{
                                                self.serviceProviders.append(request)
                                            }
                                            
                                        case .modified:
                                            
                                            let requestId = documentChange.document.documentID
                                            
                                            let newRequest = Request(dict: requestData, id: requestId, userRequest: user, userProvider: userProvider, requestType: service)
                                            print(newRequest)
                                            let currentUser = Auth.auth().currentUser
                                            if let currentUser = currentUser, currentUser.uid ==  user.id{
                                            if newRequest.title != "" && newRequest.haveProvider && !newRequest.accept{
                                                self.serviceProvidersTableView.beginUpdates()
                                                self.serviceProviders.append(newRequest)
                                                self.serviceProvidersTableView.insertRows(at: [IndexPath(row:self.serviceProviders.count - 1,section: 0)],with: .automatic)
                                                self.serviceProvidersTableView.endUpdates()
                                            }
                                            if !newRequest.haveProvider && !newRequest.accept{
                                                if let deleteIndex = self.serviceProviders.firstIndex(where: {$0.id == requestId}){
                                                    self.serviceProviders.remove(at: deleteIndex)
                                                    self.serviceProvidersTableView.beginUpdates()
                                                    self.serviceProvidersTableView.deleteRows(at: [IndexPath(row: deleteIndex, section: 0)], with: .automatic)
                                                    self.serviceProvidersTableView.endUpdates()
                                                    
                                                }
                                            }
                                            if request.done == true{
                                                self.serviceProvidersTableView.beginUpdates()
                                                self.serviceProviders.append(newRequest)
                                                self.serviceProvidersTableView.insertRows(at: [IndexPath(row:self.serviceProviders.count - 1,section: 0)],with: .automatic)
                                                self.serviceProvidersTableView.endUpdates()
                                            }
                                            }
                                        case .removed:
                                            let requestId = documentChange.document.documentID
                                            if let deleteIndex = self.serviceProviders.firstIndex(where: {$0.id == requestId}){
                                                self.serviceProviders.remove(at: deleteIndex)
                                                self.serviceProvidersTableView.beginUpdates()
                                                self.serviceProvidersTableView.deleteRows(at: [IndexPath(row: deleteIndex, section: 0)], with: .automatic)
                                                self.serviceProvidersTableView.endUpdates()
                                                
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



extension ServiceProvidersViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if serviceProviders.count == 0{
            tableView.setEmptyMessage("noProvider".localizes)
        }else {
            tableView.restore()
            
        }
        return serviceProviders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "serviceProvidersCell" , for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        if serviceProviders[indexPath.row].done == true{
            content.text = serviceProviders[indexPath.row].userProvider.name
            content.secondaryText = "rating"
        }else{
        content.text = serviceProviders[indexPath.row].title
        content.secondaryText = serviceProviders[indexPath.row].price
        }
        cell.accessoryType = .detailButton
        cell.selectionStyle = .none
        cell.contentConfiguration = content
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        let alert = UIAlertController(title: serviceProviders[indexPath.row].userProvider.name , message: "\(serviceProviders[indexPath.row].userProvider.phoneNumber)\n \(serviceProviders[indexPath.row].userProvider.rating)", preferredStyle: .alert)
        if serviceProviders[indexPath.row].done == true{
           

            let rating = UIAlertAction(title: "rating".localizes, style: .cancel) { Action in
                
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let viewController = storyboard.instantiateViewController(identifier: "ReviweCV") as? ReviewProviderViewController{
                
                
                viewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                    self.selectUser = self.serviceProviders[indexPath.row].userProvider
                    viewController.selectUser = self.selectUser
                    viewController.id = self.serviceProviders[indexPath.row].id
            self.present(viewController, animated: true, completion: nil)
                }
            }
            alert.addAction(rating)
            self.present(alert, animated: true, completion: nil)
            
        }else{
        let cancelAction = UIAlertAction(title: "reject".localizes, style: .cancel) { [self] Action in
            let db = Firestore.firestore()
            let ref = db.collection("requests")
            
            let priceData:[String:Any] = ["price": self.serviceProviders[indexPath.row].price,
                                          "requestsId" : serviceProviders[indexPath.row].userRequest.id,
                                          "providerId":serviceProviders[indexPath.row].userProvider.id,
                                          "title" : self.serviceProviders[indexPath.row].title ,
                                          "details" : self.serviceProviders[indexPath.row].details ,
                                          "createAt" : FieldValue.serverTimestamp(),
                                          "haveProvider": false,
                                          "serviceId": self.serviceProviders[indexPath.row].requestType.id,
                                          "latitude" : self.serviceProviders[indexPath.row].latitude,
                                          "longitude" : self.serviceProviders[indexPath.row].longitude,
                                          "accept" : false,
                                          "done" : false
            ]
            ref.document(self.serviceProviders[indexPath.row].id).setData(priceData) { error in
                if let error = error {
                    print("FireStore Error",error.localizedDescription)
                }
            }
            
        }
        let sendAction = UIAlertAction(title: "accept".localizes, style: .default) { Action in
            let db = Firestore.firestore()
            let ref = db.collection("requests")
            
            let priceData:[String:Any] = ["price": self.serviceProviders[indexPath.row].price,
                                          "requestsId" : self.serviceProviders[indexPath.row].userRequest.id,
                                          "providerId":self.serviceProviders[indexPath.row].userProvider.id,
                                          "title" : self.serviceProviders[indexPath.row].title ,
                                          "details" : self.serviceProviders[indexPath.row].details ,
                                          "createAt" : FieldValue.serverTimestamp(),
                                          "haveProvider": true,
                                          "serviceId": self.serviceProviders[indexPath.row].requestType.id,
                                          "latitude" : self.serviceProviders[indexPath.row].latitude,
                                          "longitude" : self.serviceProviders[indexPath.row].longitude,
                                          "accept" : true,
                                          "done" : false
            ]
            ref.document(self.serviceProviders[indexPath.row].id).setData(priceData) { error in
                if let error = error {
                    print("FireStore Error",error.localizedDescription)
                }
            }
           
        }
        let deleteAction = UIAlertAction(title: "delete".localizes, style: .destructive){ Action in
            
            let ref = Firestore.firestore().collection("requests")
            ref.document(self.serviceProviders[indexPath.row].id).delete { error in
                if let error = error {
                    print("Error in db delete",error)
                }
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(sendAction)
        alert.addAction(deleteAction)
            self.present(alert, animated: true, completion: nil)
        }
       
    }
}
