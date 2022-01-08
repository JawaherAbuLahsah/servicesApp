//
//  AddServicesViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 02/06/1443 AH.
//

import UIKit
import Firebase
class AddServicesViewController: UIViewController {
    
    @IBOutlet weak var enNameLabel: UILabel!{
        didSet{
            enNameLabel.text = "enName".localizes
        }
    }
    @IBOutlet weak var enNameTextField: UITextField!{
        didSet{
            enNameTextField.delegate = self
        }
    }
    @IBOutlet weak var arNameLabel: UILabel!{
        didSet{
            arNameLabel.text = "arName".localizes
        }
    }
    @IBOutlet weak var arNameTextField: UITextField!{
        didSet{
            arNameTextField.delegate = self
        }
    }
    @IBOutlet weak var serviceImage: UIImageView!{
        didSet{
            serviceImage.isUserInteractionEnabled = true
            let tabGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
            serviceImage.addGestureRecognizer(tabGesture)
        }
    }
    @IBOutlet weak var actionButton: UIButton!
    let activityIndicator = UIActivityIndicatorView()
    let imagePickerController = UIImagePickerController()
    var selectServices : Service?
    var selectedServiceImage:UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        if let selectServices = selectServices{
            enNameTextField.text = selectServices.name
            arNameTextField.text = selectServices.name
            serviceImage.lodingImage(selectServices.imageUrl)
            
            actionButton.setTitle("edit".localizes, for: .normal)
            let deleteBarButton = UIBarButtonItem(image: UIImage(systemName: "trash.fill"), style: .plain, target: self, action: #selector(handleDelete))
            self.navigationItem.rightBarButtonItem = deleteBarButton
        }else {
            actionButton.setTitle("save".localizes, for: .normal)
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    
    @IBAction func handleActionTouch(_ sender: Any) {
        if let image = serviceImage.image,
           let imageData = image.jpegData(compressionQuality: 0.25),
           let enName = enNameTextField.text,
           let arName = arNameTextField.text{
            var serviceId = ""
            if let selectServices = selectServices {
                serviceId = selectServices.id
            }else{
                serviceId = "\(Firebase.UUID())"
            }
            let storageRef = Storage.storage().reference(withPath: "services/\(serviceId)")
            let updloadMeta = StorageMetadata.init()
            updloadMeta.contentType = "image/png"
            storageRef.putData(imageData,metadata: updloadMeta){storageMeta,error in
                if let error = error{
                    print("Upload error",error.localizedDescription)
                }
                storageRef.downloadURL { url, error in
                    var serviceData = [String:Any]()
                    if let url = url {
                        let db = Firestore.firestore()
                        let ref = db.collection("services")
                        if let selectServices = self.selectServices {
                            serviceData = [
                                "id":selectServices.id,
                                "arName":arName,
                                "enName":enName,
                                "imageUrl":url.absoluteString
                            ]
                        }else{
                            serviceData = [
                                "id":serviceId,
                                "arName":arName,
                                "enName":enName,
                                "imageUrl":url.absoluteString
                            ]
                        }
                        ref.document(serviceId).setData(serviceData) { error in
                            if let error = error {
                                print("FireStore Error",error.localizedDescription)
                            }
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
            
        }
    }


@objc func handleDelete(){
    let ref = Firestore.firestore().collection("services")
    if let selectServices = selectServices {
        Activity.showIndicator(parentView: self.view, childView: activityIndicator)
        ref.document(selectServices.id).delete { error in
            if let error = error {
                print("Error in db delete",error)
            }else {
                
                let storageRef = Storage.storage().reference(withPath: "services/\(selectServices.id)")
                storageRef.delete { error in
                    if let error = error {
                        print("Error in storage delete",error)
                    } else {
                        self.activityIndicator.stopAnimating()
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
}
    
//    @IBAction func logout(_ sender: Any) {
//        do {
//            try Auth.auth().signOut()
//            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LandingNavigationController") as? UINavigationController {
//                vc.modalPresentationStyle = .fullScreen
//                self.present(vc, animated: true, completion: nil)
//            }
//        } catch  {
//            print("ERROR in signout",error.localizedDescription)
//        }
//
//    }
    
}
extension AddServicesViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
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
        serviceImage.image = chosenImage
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
}
extension AddServicesViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
