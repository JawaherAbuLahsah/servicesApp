//
//  ServicesViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 22/05/1443 AH.
//

import UIKit
import Firebase
class ServicesViewController: UIViewController {
    
    @IBOutlet weak var servicesCollectionView: UICollectionView!{
        didSet{
            servicesCollectionView.delegate = self
            servicesCollectionView.dataSource = self
        }
    }
    
    var services = [Service]()
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
                    self.servicesCollectionView.reloadData()
                    print(self.services)
                }
                
            }
            
        }
        
    }
}


extension ServicesViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return services.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "serviceCell", for: indexPath) as! ServiceCollectionViewCell
        cell.serviceNameLabel.text = services[indexPath.row].name
        print(services[indexPath.row].name)
        return cell
    }

    
}
