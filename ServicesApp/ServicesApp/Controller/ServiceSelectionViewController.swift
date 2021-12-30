//
//  ServiceSelectionViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 22/05/1443 AH.
//

import UIKit
import Firebase
class ServiceSelectionViewController: UIViewController {
    
    @IBOutlet weak var serviceSelectionTableView: UITableView!{
        didSet{
            serviceSelectionTableView.dataSource = self
            serviceSelectionTableView.delegate = self
        }
    }
    var services = [Service]()
    var selectedServices = [Service]()
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        
        // Do any additional setup after loading the view.
    }
    
    
    func getData(){
        let db = Firestore.firestore()
        db.collection("services").order(by: "name").addSnapshotListener { snapshot, error in
            
            if let error = error{
                print(error)
            }
            if let snapshot = snapshot{
                snapshot.documentChanges.forEach { documentChange in
                    let serviceData = documentChange.document.data()
                    let service = Service(dict: serviceData)
                    self.services.append(service)
                    self.serviceSelectionTableView.reloadData()
                    print(self.services)
                }
                
            }
            
        }
        
    }
    
    @IBAction func handleSave(_ sender: Any) {
        //add
        if let currentUser = Auth.auth().currentUser , !selectedServices.isEmpty{
            let db = Firestore.firestore()
            db.collection("users").document(currentUser.uid).getDocument { snapshot, error in
                if let error = error{
                    print(error)
                }
                if let snapshot = snapshot,
                   let userData = snapshot.data(){
                                      let user = User(dict: userData)
                    let dataBase = Firestore.firestore()
                   // if let providerId = userData["id"] as? String{
                                            let userData:[String:Any] = [
                                                "id" : user.id,
                                                "name" : user.name,
                                                "email" : user.email,
                                                "phoneNumber" : user.phoneNumber,
                                                "userType" : user.userType,
                                                "profilePictuer": user.profilePictuer,
                                                "service":self.selectedServices
                                            ]
                       // userData["service"] = self.selectedServices
                        dataBase.collection("users").document(user.id).setData(userData){ error in
                            if let error = error{
                                print(error)
                                
                            }else{
                                
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                
                                let mainTabBarController = storyboard.instantiateViewController(identifier: "ServiceProviderNavigationController")
                                mainTabBarController.modalPresentationStyle = .fullScreen
                                
                                self.present(mainTabBarController, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    
}
extension ServiceSelectionViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "serviceSelectionCell", for: indexPath) as! ServiceSelectionTableViewCell
        cell.serviceNameLabel.text = services[indexPath.row].name

        let selectServiceSwitch = UISwitch()
        
        selectServiceSwitch.tag = indexPath.row
        selectServiceSwitch.addTarget(self, action: #selector(didChangeswitch(_:)), for: .valueChanged)
        selectServiceSwitch.isOn = false
        cell.accessoryView = selectServiceSwitch

        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    @objc func didChangeswitch(_ sender:UISwitch){
        if sender.isOn{
            selectedServices.append(services[sender.tag])
            print("this>>>",selectedServices)
        }
    }
}
