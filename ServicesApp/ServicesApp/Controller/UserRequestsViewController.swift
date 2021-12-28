//
//  UserRequestsViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 22/05/1443 AH.
//






import UIKit
import Firebase
class UserRequestsViewController: UIViewController {
    
    
    @IBOutlet weak var requestsTableView: UITableView!{
        didSet{
            requestsTableView.delegate = self
            requestsTableView.dataSource = self
        }
    }
    var userRequests = [Request]()
        var selectedRequests : User?
    //    var provider : User?
    var requestr = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
    }
    
    
    func getData(){
        let db = Firestore.firestore()
        db.collection("requests").addSnapshotListener { snapshot, error in
            if let error = error{
                print("ERROR in get requests data in userReuqests ",error)
            }
            if let snapshot = snapshot{
                snapshot.documentChanges.forEach { documentChange in
                    let requestData = documentChange.document.data()
                    
                    
                    if let currentUser = Auth.auth().currentUser{
                        db.collection("users").document(currentUser.uid).getDocument { userProviderSnapshot, error in
                            if let error = error{
                                print("Error in get provider data ",error)
                            }
                            if let userId = requestData["requestsId"] as? String{
//                                self.requestr = userId
//                                print("'llll'",self.requestr)
                                db.collection("users").document(userId).getDocument { userSnapshot, error in
                                    if let error = error{
                                        print("3",error)
                                    }
                                    
                                    switch documentChange.type{
                                    case .added:
                                        
                                        if let userProviderSnapshot = userProviderSnapshot,
                                           let userProviderData = userProviderSnapshot.data(),
                                           let userSnapshot = userSnapshot,
                                           let userData = userSnapshot.data(){
                                            let user = User(dict: userData)
                                            let userProvider = User(dict: userProviderData)
                                            print(user)
                                            print(userProvider)
                                            let request = Request(dict: requestData,id: documentChange.document.documentID,userRequest: user ,userProvider: userProvider)
                                            //print(request)
                                            
                                            self.userRequests.append(request)
                                            self.requestsTableView.reloadData()
                                            print(self.userRequests)
                                        }
                                        // }
                                        
                                        //}
                                    case .modified:
                                        let requestId = documentChange.document.documentID
                                        if let updateIndex = self.userRequests.firstIndex(where: {$0.id == requestId}){
                                            //                            let newRequest =  Request(dict: requestData,id: requestId)
                                            //                            self.userRequests[updateIndex] = newRequest
                                            
                                            
                                            self.requestsTableView.beginUpdates()
                                            self.userRequests.remove(at: updateIndex)
                                            self.requestsTableView.deleteRows(at: [IndexPath(row: updateIndex, section: 0)], with: .left)
                                            // self.requestsTableView.insertRows(at: [IndexPath(row: updateIndex, section: 0)], with: .left)
                                            self.requestsTableView.endUpdates()
                                            
                                            
                                        }
                                    case .removed:
                                        let requestId = documentChange.document.documentID
                                        if let deleteIndex = self.userRequests.firstIndex(where: {$0.id == requestId}){
                                            self.userRequests.remove(at: deleteIndex)
                                            self.requestsTableView.beginUpdates()
                                            self.requestsTableView.deleteRows(at: [IndexPath(row: deleteIndex, section: 0)], with: .automatic)
                                            self.requestsTableView.endUpdates()
                                            
                                        }
                                        
                                    }
                                }
                            }
                        }
                    }
                    
                }
            }
            
            func getProviderData(){
                //        if let currentUser = Auth.auth().currentUser{
                //            let db = Firestore.firestore()
                //            db.collection("user").document(currentUser.uid).addSnapshotListener { snapshot, error in
                //
                //                if let error = error{
                //                    print(error)
                //                }
                //                if let snapshot = snapshot{
                //
                //                    if let userData = snapshot.data(){
                //                        let user = User(dict: userData)
                //                        self.provider = user
                //
                //                    }
                //
                //                }
                //            }
                //        }
            }
                
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                        let sender = segue.destination as! ServiceProvidersViewController
                        sender.selectedRequests = selectedRequests
                    }
}
        extension UserRequestsViewController:UITableViewDelegate,UITableViewDataSource{
            func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return userRequests.count
            }
            
            func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: "requestCell", for: indexPath)
                var content = cell.defaultContentConfiguration()
                if userRequests[indexPath.row].haveProvider {
                    //not work
                    content.text = "no requset"
                }else{
                    content.text = userRequests[indexPath.row].title
                    
                    cell.accessoryType = .detailButton
                }
                cell.contentConfiguration = content
                return cell
            }
            
            
            
            
            func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                let alert = UIAlertController(title: userRequests[indexPath.row].title, message: "\(userRequests[indexPath.row].details) \n \(userRequests[indexPath.row].userRequest.name)", preferredStyle: .alert)
                alert.addTextField { (textField:UITextField) in
                    textField.placeholder = "add price"
                    textField.keyboardType = .decimalPad
                    let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 44.0))
                    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                    let DoneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.tapDone))
                    toolBar.setItems([flexibleSpace, DoneButton], animated: false)
                    textField.inputAccessoryView = toolBar
                }
                
                let cancelAction = UIAlertAction(title: "cancel", style: .cancel) { Action in
                    //remove from table
                }
                let sendAction = UIAlertAction(title: "send", style: .default) { Action in
                    //change Price
                    if let fields = alert.textFields{
                        let price = fields[0]
                        if let price = price.text, !price.isEmpty{
                            print(price)
                            // self.performSegue(withIdentifier: "toServiceProvidersVC", sender: self)
                            let db = Firestore.firestore()
                            let ref = db.collection("requests")
                            
                            let priceData:[String:Any] = ["price": price,
                                                          "requestsId" : self.userRequests[indexPath.row].userRequest.id,
                                                          "providerId":self.userRequests[indexPath.row].userProvider.id,
                                                          "title" : self.userRequests[indexPath.row].title ,
                                                          "details" : self.userRequests[indexPath.row].details ,
                                                          "createAt" : FieldValue.serverTimestamp(),
                                                          "haveProvider":true
                            ]
                            ref.document(self.userRequests[indexPath.row].id).setData(priceData) { error in
                                if let error = error {
                                    print("FireStore Error",error.localizedDescription)
                                }
                            }
                        }else{
                            print("oh no")
                        }
                    }
                    self.selectedRequests = self.userRequests[indexPath.row].userProvider
                }
                alert.addAction(cancelAction)
                alert.addAction(sendAction)
                self.present(alert, animated: true, completion: nil)
            }
            @objc func tapDone() {
                self.view.endEditing(true)
            }
        }
