//
//  RegistrationViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 21/05/1443 AH.
//

import UIKit
import Firebase
import CoreLocation

class RegistrationViewController: UIViewController ,CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    @IBOutlet weak var showPasswordButton: UIButton!
    @IBOutlet weak var registrationView: UIView!{
        didSet{
    registrationView.layer.cornerRadius = 40
            registrationView.layer.shadowRadius = 30
            registrationView.layer.shadowOpacity = 0.5
        }
    }
    @IBOutlet weak var userTypeButton: UIButton!{
        didSet{
            userTypeButton.layer.borderWidth = 0.5
            userTypeButton.layer.borderColor = UIColor.systemBlue.cgColor
            userTypeButton.layer.cornerRadius = userTypeButton.frame.size.width / 2.0
            userTypeButton.backgroundColor = .systemBackground
        }
    }
    
    @IBOutlet weak var userTypeLabel: UILabel!{
        didSet{
            userTypeLabel.text = "provider".localizes
        }
    }
    @IBOutlet weak var userNameLabel: UILabel!{
        didSet{
            userNameLabel.text = "name".localizes
        }
    }
    @IBOutlet weak var userNameTaxtField: UITextField!{
        didSet{
            userNameTaxtField.delegate = self
        }
    }
    @IBOutlet weak var userEmailLabel: UILabel!{
        didSet{
            userEmailLabel.text = "email".localizes
        }
    }
    @IBOutlet weak var userEmailTextField: UITextField!{
        didSet{
            userEmailTextField.delegate = self
        }
    }
    @IBOutlet weak var userPhoneNumberLabel: UILabel!{
        didSet{
            userPhoneNumberLabel.text = "phone".localizes
        }
    }
    @IBOutlet weak var userPhoneNumberTextField: UITextField!{
        didSet{
            userPhoneNumberTextField.delegate = self
        }
    }
    @IBOutlet weak var passWordLabel: UILabel!{
        didSet{
            passWordLabel.text = "password".localizes
        }
    }
    @IBOutlet weak var passWordTextField: UITextField!{
        didSet{
            passWordTextField.delegate = self
            passWordTextField.isSecureTextEntry = true
        }
    }
    @IBOutlet weak var signInButton: UIButton!{
        didSet{
            signInButton.setTitle("signIn".localizes, for: .normal)
            signInButton.layer.cornerRadius = 10
        }
    }
    
    var activityIndicator = UIActivityIndicatorView()
    var isProvider = false
    @IBAction func specifyType(_ sender: Any) {
        if isProvider{
            userTypeButton.backgroundColor = .systemBackground
            isProvider = false
        }else{
            userTypeButton.backgroundColor = .systemBlue
            isProvider = true
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
                tap.cancelsTouchesInView = false
                view.addGestureRecognizer(tap)
    }
    
    var latitude = 0.0
    var longitude = 0.0
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        latitude = locValue.latitude
        longitude = locValue.longitude
    }
    var isShowPassword = true
    @IBAction func showPassword(_ sender: Any) {
        if isShowPassword {
            passWordTextField.isSecureTextEntry = false
            
            showPasswordButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            isShowPassword = false
        }else{
            passWordTextField.isSecureTextEntry = true
            showPasswordButton.setImage(UIImage(systemName: "eye"), for: .normal)
            isShowPassword = true
        }
    }
    
    
    
    
    
    let image = UIImage(systemName: "person.fill")
    @IBAction func handleRegister(_ sender: Any) {
        
        if let name = userNameTaxtField.text ,
           let image = image,
           let imageData = image.jpegData(compressionQuality: 0.25),
           let email = userEmailTextField.text ,
           let phoneNumber = userPhoneNumberTextField.text ,
           let password = passWordTextField.text  {
            Activity.showIndicator(parentView: self.view, childView: activityIndicator)
            Auth.auth().createUser(withEmail: email, password: password) { authDataResult, error in
                if let error = error{
                    
                        Alert.showAlertError("check".localizes)
                        self.present(Alert.alert, animated: true, completion: nil)
                    Activity.removeIndicator(parentView: self.view, childView: self.activityIndicator)
                }
                if let authDataResult = authDataResult {
                    
                    let storageReference = Storage.storage().reference(withPath: "users/\(authDataResult.user.uid)")
                    let uploadMeta = StorageMetadata.init()
                    uploadMeta.contentType = "image/png"
                    storageReference.putData(imageData, metadata: uploadMeta) { storageMeta, error in
                        if let _ = error {
                            Alert.showAlertError("check".localizes)
                            self.present(Alert.alert, animated: true, completion: nil)
                            Activity.removeIndicator(parentView: self.view, childView: self.activityIndicator)
                        }
                        storageReference.downloadURL { url, error in
                            if let error = error {
                                Alert.showAlertError(error.localizedDescription)
                                self.present(Alert.alert, animated: true, completion: nil)
                            }
                            if let url = url {
                                print("URL",url.absoluteString)
                                
                                let dataBase = Firestore.firestore()
                                let userData:[String:Any] = [
                                    "id" : authDataResult.user.uid,
                                    "name" : name,
                                    "email" : email,
                                    "phoneNumber" : phoneNumber,
                                    "userType" : self.isProvider,
                                    "profilePictuer": url.absoluteString,
                                    "service":[],
                                    "latitude" : self.latitude,
                                    "longitude" : self.longitude
                                ]
                                
                                dataBase.collection("users").document(authDataResult.user.uid).setData(userData){ error in
                                    if let error = error{
                                        print(error)
                                        
                                    }else{
                                        
                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                        Activity.removeIndicator(parentView: self.view, childView: self.activityIndicator)
                                        if self.isProvider{
                                            let mainTabBarController = storyboard.instantiateViewController(identifier: "ServicesSelectionNavigationController")
                                            mainTabBarController.modalPresentationStyle = .fullScreen

                                            self.present(mainTabBarController, animated: true, completion: nil)
                                        }else{
                                            let mainTabBarController = storyboard.instantiateViewController(identifier: "ServiceRequesterNavigationController")
                                            mainTabBarController.modalPresentationStyle = .fullScreen

                                            self.present(mainTabBarController, animated: true, completion: nil)
                                        }
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }else{
            Alert.showAlertError("check".localizes)
            self.present(Alert.alert, animated: true, completion: nil)
            Activity.removeIndicator(parentView: self.view, childView: self.activityIndicator)
        }
    }
}


extension RegistrationViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
