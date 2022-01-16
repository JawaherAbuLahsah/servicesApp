//
//  ServiceSelectionViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 22/05/1443 AH.
//

import UIKit
import Firebase
class ServiceSelectionViewController: UIViewController {
    
    @IBOutlet weak var saveButton: UIButton!{
        didSet{
            saveButton.setTitle("save".localizes, for: .normal)
        }
    }
    @IBOutlet weak var serviceSelectionTableView: UITableView!{
        didSet{
            serviceSelectionTableView.dataSource = self
            serviceSelectionTableView.delegate = self
        }
    }
    var services = [Service]()
    var selectedServices = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        
    }
    
    
    func getData(){
        let db = Firestore.firestore()
        db.collection("services").addSnapshotListener { snapshot, error in
            
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
        
        if let currentUser = Auth.auth().currentUser{
            let db = Firestore.firestore()
            db.collection("users").document(currentUser.uid).getDocument { snapshot, error in
                if let error = error{
                    print(error)
                }
                
                if let snapshot = snapshot,
                   let userData = snapshot.data(){
                    let user = User(dict: userData)
                    let dataBase = Firestore.firestore()
                    //  if let address = userData["address"] as? Any{
                    let userData:[String:Any] = [
                        "id" : user.id,
                        "name" : user.name,
                        "email" : user.email,
                        "phoneNumber" : user.phoneNumber,
                        "userType" : user.userType,
                        "profilePictuer": user.profilePictuer,
                        "service":self.selectedServices,
                        "latitude" : user.latitude,
                        "longitude" : user.longitude,
                        "rating" : user.rating,
                        "numberRating": user.numberRating,
                        "numberStar":user.numberStar
                    ]
                    
                    dataBase.collection("users").document(user.id).setData(userData){ error in
                        if let error = error{
                            print("errrooooo",error)
                            
                            
                        }else{
                            print("omeokpre")
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
        //selectServiceSwitch.isOn = false
        selectServiceSwitch.tag = indexPath.row
        selectServiceSwitch.addTarget(self, action: #selector(didChangeswitch(_:)), for: .valueChanged)
        cell.accessoryView = selectServiceSwitch
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 200
//    }
    @objc func didChangeswitch(_ sender:UISwitch){
        if sender.isOn{
            selectedServices.append(services[sender.tag].id)
        }else{
            selectedServices.remove(at: sender.tag)
        }
    }
}
