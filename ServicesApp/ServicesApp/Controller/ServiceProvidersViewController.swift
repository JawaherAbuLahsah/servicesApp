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
    var selectedRequests : Request?
   // var provider : User?
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
                print(error)
            }
            if let snapshot = snapshot{
                snapshot.documentChanges.forEach { documentChange in
                    let requestData = documentChange.document.data()
                    if let currentUser = Auth.auth().currentUser{
                        db.collection("users").document(currentUser.uid).getDocument { userProviderSnapshot, error in
                            if let error = error{
                                print(error)
                            }
                            switch documentChange.type{
                            case .added:
                                if let userId = requestData["userId"] as? String{
                                
                                    db.collection("users").document(userId).getDocument { userSnapshot, error in
                                        if let error = error{
                                            print(error)
                                        }
                                        
                                        
                                        if let userSnapshot = userSnapshot,
                                           let userProviderSnapshot = userProviderSnapshot,
                                           let userProviderData = userProviderSnapshot.data(),
                                           let userData = userSnapshot.data(){
                                            let user = User(dict: userData)
                                            let userProvider = User(dict: userProviderData)
                                            let request = Request(dict: requestData,id: documentChange.document.documentID, user: userProvider)
                                            print(request)
                                            self.serviceProviders.append(request)
                                            self.serviceProvidersTableView.reloadData()
                                            print(self.serviceProviders)
                                        }
                                    }
                                    
                                }
                            case .modified:
                                let requestId = documentChange.document.documentID
                                if let updateIndex = self.serviceProviders.firstIndex(where: {$0.id == requestId}){
                                    //                            let newRequest =  Request(dict: requestData,id: requestId)
                                    //                            self.userRequests[updateIndex] = newRequest
                                    
                                    
                                    self.serviceProvidersTableView.beginUpdates()
                                    self.serviceProviders.remove(at: updateIndex)
                                    self.serviceProvidersTableView.deleteRows(at: [IndexPath(row: updateIndex, section: 0)], with: .left)
                                    // self.requestsTableView.insertRows(at: [IndexPath(row: updateIndex, section: 0)], with: .left)
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
            
        
        cell.contentConfiguration = content
        cell.accessoryType = .detailButton
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: serviceProviders[indexPath.row].user.name , message: "\(serviceProviders[indexPath.row].user.phoneNumber)", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel) { Action in
            // 
        }
        let sendAction = UIAlertAction(title: "send", style: .default) { Action in
            //go to chat
        }
        alert.addAction(cancelAction)
        alert.addAction(sendAction)
        self.present(alert, animated: true, completion: nil)
    }
    

}
