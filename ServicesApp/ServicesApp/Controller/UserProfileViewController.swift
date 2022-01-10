//
//  UserProfileViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 22/05/1443 AH.
//

import UIKit
import Firebase
class UserProfileViewController: UIViewController,HamburgerMenuControllerDelegate {
    
    @IBOutlet weak var hamburgerMenuView: UIView!
    @IBOutlet weak var hamburgerMenuConstraintLeading: NSLayoutConstraint!
    @IBOutlet weak var profileImageView: UIImageView!{
        didSet{
            profileImageView.isUserInteractionEnabled = true
            let tabGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
            profileImageView.addGestureRecognizer(tabGesture)
        }
    }
    
    @IBOutlet weak var serviceView: UIView!
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
        }
    }
    let imagePickerController = UIImagePickerController()
    var hamburgerMenuViewController:HamburgerMenuViewController?
    var isHamburgerMenuShown:Bool = false
    var providerServices = [String]()
    var userProviderData = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        imagePickerController.delegate = self
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
                                    self.profileImageView.lodingImage(user.profilePictuer)
                                    if !user.userType{
                                        self.serviceView.isHidden = true
                                    }
                                    
                                    self.userProviderData.append(user)
                                    
                                    self.providerServices = user.service
                                    self.providerServicesTableView.reloadData()
                                    
                                    
                                case .modified:
                                    let userId = documentChange.document.documentID
                                    if let updateIndex = self.userProviderData.firstIndex(where: {$0.id == userId}){
                                        if !self.providerServices.isEmpty{
                                            self.providerServicesTableView.beginUpdates()
                                            self.providerServicesTableView.deleteRows(at: [IndexPath(row: updateIndex, section: 0)], with: .left)
                                            self.providerServicesTableView.insertRows(at: [IndexPath(row: updateIndex, section: 0)], with: .left)
                                            
                                            self.providerServicesTableView.endUpdates()
                                        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toEditServiceVC"{
//            let sender = segue.destination as! ServiceSelectionViewController
//            sender.selectedServices = providerServices
            
        }
        if segue.identifier == "toEditVC"{
        let sender = segue.destination as! EditProfileViewController
        sender.providerServices = providerServices
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

extension UserProfileViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return providerServices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectedServicesCell", for: indexPath)
        cell.selectionStyle = .none
        var content = cell.defaultContentConfiguration()
        if !providerServices.isEmpty{
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
    
}
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
            self.dismiss(animated: true, completion: nil)
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
