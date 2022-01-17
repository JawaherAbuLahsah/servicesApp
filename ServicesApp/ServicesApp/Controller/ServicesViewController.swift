//
//  ServicesViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 22/05/1443 AH.
//

import UIKit
import Firebase
class ServicesViewController: UIViewController {
    // MARK: - Outlat
    @IBOutlet weak var logoutBarButton: UIBarButtonItem!
    @IBOutlet weak var servicesCollectionView: UICollectionView!{
        didSet{
            servicesCollectionView.delegate = self
            servicesCollectionView.dataSource = self
        }
    }
    @IBOutlet weak var addServiceBarButton: UIBarButtonItem!
    
    // MARK: - Definitions
    var services = [Service]()
    var selectServices : Service?
    var selectedServiceImage:UIImage?
    // MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        // Do any additional setup after loading the view.
        //TeGLA3gVl3SudOGtFtVvwbwzs192
        if let currentUser = Auth.auth().currentUser{
            if currentUser.email == "j@j.com"{
                navigationItem.rightBarButtonItem = addServiceBarButton
                navigationItem.leftBarButtonItem = logoutBarButton
            }else{
                navigationItem.rightBarButtonItem = nil
                navigationItem.leftBarButtonItem = nil
            }
        }
    }
    
    // MARK: - function get data
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
                    switch documentChange.type {
                    case .added :
                        self.services.append(service)
                        self.servicesCollectionView.reloadData()
                        print(self.services)
                    case .modified:
                        let serviceId = documentChange.document.documentID
                        if let updateIndex = self.services.firstIndex(where: {$0.id == serviceId}){
                            let newService = Service(dict: serviceData)
                            self.services[updateIndex] = newService
                            self.servicesCollectionView.reloadData()
                            
                        }
                        
                    case .removed:
                        let serviceId = documentChange.document.documentID
                        if let deleteIndex = self.services.firstIndex(where: {$0.id == serviceId}){
                            self.services.remove(at: deleteIndex)
                            self.servicesCollectionView.reloadData()
                            
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - prepare function
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toRequestDetailsVC"{
            let sender = segue.destination as! RequestDetailsViewController
            sender.selectServices = selectServices
        }else if segue.identifier == "toAddServicesVC"{
            let sender = segue.destination as! AddServicesViewController
            sender.selectServices = selectServices
            sender.selectedServiceImage = selectedServiceImage
        }else{
            
        }
    }
    
    // MARK: - logout function
    @IBAction func logout(_ sender: Any) {
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

// MARK: - extension
extension ServicesViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return services.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "serviceCell", for: indexPath) as! ServiceCollectionViewCell
        cell.serviceNameLabel.text = services[indexPath.row].name
        cell.serviceImage.lodingImage(services[indexPath.row].imageUrl)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "serviceCell", for: indexPath) as! ServiceCollectionViewCell
        selectServices = services[indexPath.row]
        selectedServiceImage = cell.serviceImage.image
        if let currentUser = Auth.auth().currentUser{
            if currentUser.email == "j@j.com"{
                performSegue(withIdentifier: "toAddServicesVC", sender: self)
            }else{
                performSegue(withIdentifier: "toRequestDetailsVC", sender: self)
            }
        }
    }
}
