//
//  UserProfileViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 22/05/1443 AH.
//

import UIKit
import Firebase
class UserProfileViewController: UIViewController,HamburgerMenuControllerDelegate {
    
    // MARK: - Outlat
    @IBOutlet var ratingStarButton: [UIButton]!{
        didSet{
            for button in ratingStarButton {
                button.isHidden = true
            }
        }
    }
    @IBOutlet weak var servicesLabel: UILabel!
    @IBOutlet weak var hamburgerMenuView: UIView!{
        didSet{
            hamburgerMenuView.isHidden = true
        }
    }
    @IBOutlet weak var hamburgerMenuConstraintLeading: NSLayoutConstraint!
    @IBOutlet weak var profileImageView: UIImageView!{
        didSet{
            profileImageView.isUserInteractionEnabled = true
            let tabGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
            profileImageView.addGestureRecognizer(tabGesture)
            profileImageView.layer.borderWidth = 2.0
            profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
            profileImageView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var serviceView: UIView!{
        didSet{
            serviceView.layer.cornerRadius = 10
            serviceView.layer.shadowRadius = 5
            serviceView.layer.shadowOpacity = 0.5
        }
    }
    @IBOutlet weak var providerServicesTableView: UITableView!{
        didSet{
            providerServicesTableView.delegate = self
            providerServicesTableView.dataSource = self
        }
    }
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userPhoneNumberLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var editProfileButton: UIButton!{
        didSet{
            editProfileButton.layer.cornerRadius = 10
            editProfileButton.setTitle("edit".localizes, for: .normal)
            editProfileButton.isHidden = true
        }
    }
    @IBOutlet weak var profileView: UIView!{
        didSet{
            profileView.layer.cornerRadius = 20
        }
    }
    @IBOutlet weak var editButton: UIButton!{
        didSet{
            editButton.layer.cornerRadius = 10
            
        }
    }
    // MARK: - Definitions
    let imagePickerController = UIImagePickerController()
    var hamburgerMenuViewController:HamburgerMenuViewController?
    var isHamburgerMenuShown:Bool = false
    var providerServices = [String]()
    var userProviderData = [User]()
    var requestsData = [Request]()
    // MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        getRequests()
        imagePickerController.delegate = self
        
        // Do any additional setup after loading the view.
    }
    // MARK: - get requests function
    func getRequests(){
        let db = Firestore.firestore()
        if let currentUser = Auth.auth().currentUser{
            
            db.collection("requests").addSnapshotListener { snapshot, error in
                
                if let error = error{
                    print("5",error)
                }
                if let snapshot = snapshot{
                    
                    snapshot.documentChanges.forEach { documentChange in
                        let requestData = documentChange.document.data()
                        
                        if let userId = requestData["requestsId"] as? String, let providerId = requestData["providerId"] as? String ,let serviceId = requestData["serviceId"] as? String{
                            print(userId,">",providerId,">>",serviceId)
                            db.collection("users").document(userId).getDocument { userSnapshot, error in
                                if let error = error{
                                    print("6",error)
                                }
                                
                                db.collection("services").document(serviceId).getDocument { serviceSnapshot, error in
                                    if let error = error{
                                        print("3",error)
                                    }
                                    
                                    
                                    if let serviceSnapshot = serviceSnapshot,
                                       let serviceData = serviceSnapshot.data(),
                                       let userSnapshot = userSnapshot,
                                       let userData = userSnapshot.data(){
                                        let user = User(dict: userData)
                                        
                                        let service = Service(dict: serviceData)
                                        
                                        let request = Request(dict: requestData,id: documentChange.document.documentID,userRequest: user ,userProvider: user , requestType: service)
                                        
                                        print(request)
                                        
                                        switch documentChange.type{
                                        case .added:
                                            
                                            if currentUser.uid ==  user.id && !request.haveProvider {
                                                self.requestsData.append(request)
                                                self.providerServicesTableView.reloadData()
                                                print(">>LL>>",self.requestsData)
                                                
                                            }
                                            
                                            
                                        case .modified:
                                            
                                            let requestId = documentChange.document.documentID
                                            
                                            let newRequest = Request(dict: requestData, id: requestId, userRequest: user, userProvider: user, requestType: service)
                                            print(newRequest)
                                            
                                            if  currentUser.uid ==  user.id{
                                                if !newRequest.haveProvider {
                                                    self.providerServicesTableView.beginUpdates()
                                                    self.requestsData.append(newRequest)
                                                    self.providerServicesTableView.insertRows(at: [IndexPath(row: self.requestsData.count - 1,section: 0)],with: .automatic)
                                                    self.providerServicesTableView.endUpdates()
                                                }
                                                if newRequest.haveProvider && newRequest.title != "" {
                                                    if let deleteIndex = self.requestsData.firstIndex(where: {$0.id == requestId}){
                                                        self.requestsData.remove(at: deleteIndex)
                                                        self.providerServicesTableView.beginUpdates()
                                                        self.providerServicesTableView.deleteRows(at: [IndexPath(row: deleteIndex, section: 0)], with: .automatic)
                                                        self.providerServicesTableView.endUpdates()
                                                        
                                                    }
                                                }
                                            }
                                            
                                            
                                        case .removed:
                                            let requestId = documentChange.document.documentID
                                            if let deleteIndex = self.requestsData.firstIndex(where: {$0.id == requestId}){
                                                self.requestsData.remove(at: deleteIndex)
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
        }
    }
    
    
    
    // MARK: - get user data
    func getData(){
        let db = Firestore.firestore()
        if let currentUser = Auth.auth().currentUser{
            
            
            
            db.collection("users").addSnapshotListener { snapshot, error in
                if let error = error{
                    print(error)
                }
                
                
                if let snapshot = snapshot{
                    snapshot.documentChanges.forEach { documentChange in
                        
                        
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
                                    self.profileImageView.lodingImage(user.profilePictuer)
                                    
                                    if user.userType{
                                        
                                        for button in self.ratingStarButton {
                                            button.isHidden = false
                                        }
                                        self.servicesLabel.text = "services".localizes
                                        self.editProfileButton.isHidden = false
                                    }else{
                                        self.servicesLabel.text = "requests".localizes
                                    }
                                    for starButton in self.ratingStarButton{
                                        let imageName = (starButton.tag < Int(user.rating) ? "star.fill" : "star")
                                        starButton.setImage(UIImage(systemName: imageName), for: .normal)
                                        starButton.tintColor = (starButton.tag < Int(user.rating) ? .systemYellow : .darkText)
                                    }
                                    
                                    self.userProviderData.append(user)
                                    DispatchQueue.main.async {
                                        if user.userType{
                                            self.providerServices = user.service
                                            self.providerServicesTableView.reloadData()
                                        }
                                    }
                                    
                                case .modified:
                                    
                                    DispatchQueue.main.async {
                                        self.userNameLabel.text = user.name
                                        self.userPhoneNumberLabel.text = user.phoneNumber
                                        self.userEmailLabel.text = user.email
                                        self.profileImageView.lodingImage(user.profilePictuer)
                                        
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
    
    
    // MARK: - prepare function
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toEditServiceVC"{
            
            
        }
        if segue.identifier == "toEditVC"{
            let sender = segue.destination as! EditProfileViewController
            sender.providerServices = providerServices
        }
    }
    
    
    
    // MARK: - Hamburger Menu
    func hideHamburgerMenu() {
        UIView.animate(withDuration: 0.2) {
            self.hamburgerMenuConstraintLeading.constant = 10
            self.view.layoutIfNeeded()
        } completion: { (status) in
            self.hamburgerMenuView.alpha = 0.0
            UIView.animate(withDuration: 0.2) {
                self.hamburgerMenuConstraintLeading.constant = -140
                self.view.layoutIfNeeded()
            } completion: { (status) in
                self.hamburgerMenuView.isHidden = true
                self.isHamburgerMenuShown = false
            }
        }
    }
    
    @IBAction func tappedOnBackView(_ sender: Any) {
        hideHamburgerMenu()
    }
    
    //show hamburgerMenu
    @IBAction func hamburgerMenu(_ sender: Any) {
        UIView.animate(withDuration: 0.2) {
            self.hamburgerMenuConstraintLeading.constant = 10
            self.view.layoutIfNeeded()
        } completion: { (status) in
            self.hamburgerMenuView.alpha = 1
            self.hamburgerMenuView.isHidden = false
            UIView.animate(withDuration: 0.2) {
                self.hamburgerMenuConstraintLeading.constant = 0
                self.view.layoutIfNeeded()
            } completion: { (status) in
                self.isHamburgerMenuShown = true
            }
        }
        hamburgerMenuView.isHidden = false
    }
}

// MARK: - Extension
extension UserProfileViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if providerServices.isEmpty {
            if requestsData.count == 0 {
                tableView.setEmptyMessage("nothing".localizes)
            }else {
                tableView.restore()
                
            }
            return requestsData.count
        }else{
            tableView.restore()
            return providerServices.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectedServicesCell", for: indexPath)
        cell.selectionStyle = .none
        var content = cell.defaultContentConfiguration()
        if providerServices.isEmpty{
            content.text = "\(requestsData[indexPath.row].title)"
            content.secondaryText = "swipe".localizes
            cell.contentConfiguration = content
        }else{
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
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if providerServices.isEmpty {
            return true
        }else{
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if providerServices.isEmpty {
            if (editingStyle == .delete) {
                if requestsData.count != 0 {
                    let ref = Firestore.firestore().collection("requests")
                    ref.document(self.requestsData[indexPath.row].id).delete { error in
                        if let error = error {
                            print("Error in db delete",error)
                        }
                    }
                }
            }
        }
    }
}
// MARK: - Extension
extension UserProfileViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    @objc func selectImage(){
        showAlert()
    }
    func showAlert(){
        let alert = UIAlertController(title: "Post Picture", message: "Pick your post image", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { Action in
            self.getImage(.camera)
        }
        let galaryAction = UIAlertAction(title: "Photo Album", style: .default) { Action in
            self.getImage(.photoLibrary)
        }
        let dismissAction = UIAlertAction(title: "Cancle", style: .cancel) { Action in
        }
        alert.addAction(cameraAction)
        alert.addAction(galaryAction)
        alert.addAction(dismissAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func getImage(_ sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            imagePickerController.sourceType = sourceType
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return}
        profileImageView.image = chosenImage
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
}
