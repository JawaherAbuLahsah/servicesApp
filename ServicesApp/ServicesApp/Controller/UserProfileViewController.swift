//
//  UserProfileViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 22/05/1443 AH.
//

import UIKit
import Firebase
class UserProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var providerServicesTableView: UITableView!{
        didSet{
            providerServicesTableView.delegate = self
            providerServicesTableView.dataSource = self
        }
    }
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userPhoneNumberLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var editProfileButton: UIButton!
    
    
    var providerServices = [String]()
    var userProviderData = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        // Do any additional setup after loading the view.
    }
    func getData(){
        let db = Firestore.firestore()
        if let currentUser = Auth.auth().currentUser{
            db.collection("users").addSnapshotListener { snapshot, error in
                if let error = error{
                    print(error)
                }
                
                
                if let snapshot = snapshot{
                    snapshot.documentChanges.forEach { documentChange in
                        // let requestData = documentChange.document.data()
                        
                        
                        db.collection("users").document(currentUser.uid).getDocument { documentSnapshot, error in
                            if let error = error{
                                print(error)
                            }
                            if let documentSnapshot = documentSnapshot,
                               let userData = documentSnapshot.data(){
                                let user = User(dict: userData)
                                
                                switch documentChange.type{
                                case .added:
                                    
                                    self.userNameLabel.text = user.name
                                    self.userPhoneNumberLabel.text = user.phoneNumber
                                    self.userEmailLabel.text = user.email
                                    
                                    self.userProviderData.append(user)
                                    self.providerServices = user.service
                                    self.providerServicesTableView.reloadData()
                                    
                                    
                                case .modified:
                                    let userId = documentChange.document.documentID
                                    if let updateIndex = self.userProviderData.firstIndex(where: {$0.id == userId}){
                                        
                                        self.providerServicesTableView.beginUpdates()
                                        
                                        self.providerServicesTableView.deleteRows(at: [IndexPath(row: updateIndex, section: 0)], with: .left)
                                        
                                        self.providerServicesTableView.deleteRows(at: [IndexPath(row: updateIndex, section: 0)], with: .left)
                                        self.providerServicesTableView.insertRows(at: [IndexPath(row: updateIndex, section: 0)], with: .left)
                                        
                                        self.providerServicesTableView.endUpdates()
                                        
                                        
                                    }
                                case .removed:
                                    let userId = documentChange.document.documentID
                                    if let deleteIndex = self.userProviderData.firstIndex(where: {$0.id == userId}){
                                        self.userProviderData.remove(at: deleteIndex)
                                        self.providerServicesTableView.beginUpdates()
                                        self.providerServicesTableView.deleteRows(at: [IndexPath(row: deleteIndex, section: 0)], with: .automatic)
                                        self.providerServicesTableView.endUpdates()
                                        
                                    }
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    
    
    
    @IBAction func handleLogout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LandingNavigationController") as? UINavigationController {
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
        } catch  {
            print("ERROR in signout",error.localizedDescription)
        }
        
    }
}

extension UserProfileViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return providerServices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectedServicesCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let db = Firestore.firestore()
        db.collection("services").document(providerServices[indexPath.row]).getDocument { documentSnapshot, error in
            if let error = error{
                print(error)
            }
            if let documentSnapshot = documentSnapshot,let data = documentSnapshot.data(){
                let service = Service(dict: data)
                content.text = service.name
                cell.contentConfiguration = content
            }
        }
        
        return cell
    }
    
    
}
