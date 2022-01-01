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
    @IBOutlet weak var cancelButton: UIButton!
    
    var serviceProviders = [Request]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getData()
    }
    
    @IBAction func handleCancel(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LandingNavigationController") as? UINavigationController {
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
        } catch  {
            print("ERROR in signout",error.localizedDescription)
        }
        
        
        //        let alert = UIAlertController(title: "" , message: "", preferredStyle: .alert)
        //
        //        let cancelAction = UIAlertAction(title: "cancel", style: .destructive) { Action in
        //            let ref = Firestore.firestore().collection("requests")
        //            if let currentUser = Auth.auth().currentUser{
        //                ref.document(currentUser.uid).delete { error in
        //                    if let error = error{
        //                        print(error)
        //                    }else{
        //                    let storageRef = Storage.storage().reference(withPath: "requests/\(currentUser.uid)")
        //                    storageRef.delete { error in
        //                        if let error = error {
        //                            print("Error in storage delete",error)
        //                        }
        //                    }
        //                }
        //            }
        //        }
        //        }
        ////        let updateAction = UIAlertAction(title: "Update", style: .default) { Action in
        ////            //go to chat
        ////        }
        //        alert.addAction(cancelAction)
        //       // alert.addAction(updateAction)
        //        self.present(alert, animated: true, completion: nil)
        //    }
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
                    switch documentChange.type{
                    case .added:
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
                                        
                                        let currentUser = Auth.auth().currentUser
                                        if let currentUser = currentUser, currentUser.uid ==  user.id, request.haveProvider{
                                            self.serviceProviders.append(request)
                                            self.serviceProvidersTableView.reloadData()
                                            print(self.serviceProviders)
                                        }
                                        
                                    }
                                }
                            }
                        }
                        }
                    case .modified:
                        
                        let requestId = documentChange.document.documentID
                        if let updateIndex = self.serviceProviders.firstIndex(where: {$0.id == requestId}){
                            
                            self.serviceProvidersTableView.beginUpdates()
                            // self.serviceProviders.remove(at: updateIndex)
                            
                            self.serviceProvidersTableView.deleteRows(at: [IndexPath(row: updateIndex, section: 0)], with: .left)
                            self.serviceProvidersTableView.insertRows(at: [IndexPath(row: updateIndex, section: 0)], with: .left)
                            self.serviceProvidersTableView.endUpdates()
                            
                            
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



extension ServiceProvidersViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serviceProviders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "serviceProvidersCell" , for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        
        content.text = serviceProviders[indexPath.row].title
        content.secondaryText = serviceProviders[indexPath.row].price
        
        cell.accessoryType = .detailButton
        
        cell.contentConfiguration = content
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        let alert = UIAlertController(title: serviceProviders[indexPath.row].userProvider.name , message: "\(serviceProviders[indexPath.row].userProvider.phoneNumber)", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "cancel".localizes, style: .cancel) { [self] Action in
            let db = Firestore.firestore()
            let ref = db.collection("requests")
            
            let priceData:[String:Any] = ["price": self.serviceProviders[indexPath.row].price,
                                          "requestsId" : serviceProviders[indexPath.row].userRequest.id,
                                          "providerId":serviceProviders[indexPath.row].userProvider.id,
                                          "title" : self.serviceProviders[indexPath.row].title ,
                                          "details" : self.serviceProviders[indexPath.row].details ,
                                          "createAt" : FieldValue.serverTimestamp(),
                                          "haveProvider": false
            ]
            ref.document(self.serviceProviders[indexPath.row].id).setData(priceData) { error in
                if let error = error {
                    print("FireStore Error",error.localizedDescription)
                }
            }
            
        }
        let sendAction = UIAlertAction(title: "send".localizes, style: .default) { Action in
            let ref = Firestore.firestore().collection("requests")
            ref.document(self.serviceProviders[indexPath.row].id).delete { error in
                if let error = error {
                    print("Error in db delete",error)
                }
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainTabBarController = storyboard.instantiateViewController(identifier: "ChatNavigationController")
            mainTabBarController.modalPresentationStyle = .fullScreen
            
            self.present(mainTabBarController, animated: true, completion: nil)
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
