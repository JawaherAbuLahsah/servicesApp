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
    }
    
}
extension ServiceSelectionViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "serviceSelectionCell", for: indexPath) as! ServiceSelectionTableViewCell
        cell.serviceNameLabel.text = services[indexPath.row].name
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
}
