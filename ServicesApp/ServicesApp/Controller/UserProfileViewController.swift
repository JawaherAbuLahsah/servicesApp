//
//  UserProfileViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 22/05/1443 AH.
//

import UIKit
import Firebase
class UserProfileViewController: UIViewController {
    let imagePickerController = UIImagePickerController()
    @IBOutlet weak var profileImageView: UIImageView!{
        didSet{
            profileImageView.isUserInteractionEnabled = true
            let tabGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
            profileImageView.addGestureRecognizer(tabGesture)
        }
    }
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userPhoneNumberLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var editProfileButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        // Do any additional setup after loading the view.
    }
    
    
    func getData(){
        let db = Firestore.firestore()
        if let currentUser = Auth.auth().currentUser{
            db.collection("users").document(currentUser.uid).getDocument { snapshot, error in
                if let error = error{
                    print(error)
                }
                if let snapshot = snapshot,
                   let userData = snapshot.data(){
                   if let name = userData["name"] as? String,
                    let phoneNumber = userData["phoneNumber"] as? String,
                    let email = userData["email"] as? String{
                        self.userNameLabel.text = name
                        self.userPhoneNumberLabel.text = phoneNumber
                        self.userEmailLabel.text = email
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
