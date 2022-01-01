//
//  EditProfileViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 26/05/1443 AH.
//

import UIKit
import Firebase
class EditProfileViewController: UIViewController {
    let imagePickerController = UIImagePickerController()
    @IBOutlet weak var profileImageView: UIImageView!{
        didSet{
            profileImageView.isUserInteractionEnabled = true
            let tabGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
            profileImageView.addGestureRecognizer(tabGesture)
        }
    }
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    var providerServices = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func handleSave(_ sender: Any) {
        if let name = userNameTextField.text,
           let email = emailTextField.text,
           let phoneNumber = phoneNumberTextField.text ,
           let image = profileImageView.image,
           let imageData = image.jpegData(compressionQuality: 0.25),
           let currentUser = Auth.auth().currentUser{
            currentUser.updateEmail(to: email) { error in
                if let error = error {
                    print(error)
                }else{
                    let storageReference = Storage.storage().reference(withPath: "users/\(currentUser.uid)")
                    let uploadMeta = StorageMetadata.init()
                    uploadMeta.contentType = "image/png"
                    storageReference.putData(imageData, metadata: uploadMeta) { storageMeta, error in
                        if let error = error {
                            print("Registration Storage Error",error.localizedDescription)
                            
                        }
                        storageReference.downloadURL { url, error in
                            if let error = error {
                                print("Registration Storage Download Url Error",error.localizedDescription)
                                
                            }
                            if let url = url {
                                print("URL",url.absoluteString)
                                
                                
                                let db = Firestore.firestore()
                                db.collection("users").document(currentUser.uid).getDocument { userSnapshot, error in
                                    if let error = error{
                                        print("Error in get provider data ",error)
                                    }
                                    if let userSnapshot = userSnapshot,
                                       let userData = userSnapshot.data(){
                                        let user = User(dict: userData)
                                        let dataBase = Firestore.firestore()
                                        let userData:[String:Any]
                                        if user.userType{
                                         userData = [
                                            "id" : currentUser.uid,
                                            "name" : name,
                                            "email" : email,
                                            "phoneNumber" : phoneNumber,
                                            "userType" : user.userType,
                                            "profilePictuer": url.absoluteString,
                                            "service":self.providerServices,
                                            "address":user.address
                                        ]
                                        }else{
                                        userData = [
                                            "id" : currentUser.uid,
                                            "name" : name,
                                            "email" : email,
                                            "phoneNumber" : phoneNumber,
                                            "userType" : user.userType,
                                            "profilePictuer": url.absoluteString,
                                            "service":[],
                                            "address":user.address
                                        ]
                                        }
                                        dataBase.collection("users").document(currentUser.uid).setData(userData){ error in
                                            if let error = error{
                                                print(error)
                                                
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
        self.dismiss(animated: true, completion: nil)
    }
    
}
extension EditProfileViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
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
