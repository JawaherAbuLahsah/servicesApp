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
    
    var serviceProviders = [User]()
    var selectedRequests : Request?
   // var provider : User?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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

}
extension ServiceProvidersViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serviceProviders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "serviceProvidersCell" , for: indexPath)
        var content = cell.defaultContentConfiguration()
        if let selectedRequests = selectedRequests{
            content.text = serviceProviders[indexPath.row].name
            content.secondaryText = selectedRequests.price
            
        }
        cell.contentConfiguration = content
        cell.accessoryType = .detailButton
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: serviceProviders[indexPath.row].name , message: "\(serviceProviders[indexPath.row].phoneNumber)", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel) { Action in
            //remove from table
        }
//        let sendAction = UIAlertAction(title: "send", style: .default) { Action in
//            //go to chat
//        }
        alert.addAction(cancelAction)
       // alert.addAction(sendAction)
        self.present(alert, animated: true, completion: nil)
    }
    

}
