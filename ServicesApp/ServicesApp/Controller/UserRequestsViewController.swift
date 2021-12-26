//
//  UserRequestsViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 22/05/1443 AH.
//

import UIKit

class UserRequestsViewController: UIViewController {

    @IBOutlet weak var requestsTableView: UITableView!{
        didSet{
            requestsTableView.delegate = self
            requestsTableView.dataSource = self
        }
    }
    var userRequests = [Request]()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

}
extension UserRequestsViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "requestCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = userRequests[indexPath.row].title
        cell.contentConfiguration = content
        cell.accessoryType = .detailButton
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: userRequests[indexPath.row].title, message: userRequests[indexPath.row].details, preferredStyle: .alert)
        alert.addTextField { (textField) in
                    textField.placeholder = "add price"
                }
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel) { Action in
            //remove from table
        }
        let sendAction = UIAlertAction(title: "send", style: .default) { Action in
            //go to requester
        }
        alert.addAction(cancelAction)
        alert.addAction(sendAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}
