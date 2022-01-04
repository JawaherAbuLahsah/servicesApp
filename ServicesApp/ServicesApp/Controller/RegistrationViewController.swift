//
//  RegistrationViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 21/05/1443 AH.
//

import UIKit
import Firebase
import CoreLocation
//import Geofirestore

class RegistrationViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var registrationView: UIView!{
        didSet{
    registrationView.layer.cornerRadius = 40
//    registrationView.layer.shadowColor = UIColor.black.cgColor
//    registrationView.layer.shadowOpacity = 0.3
//    registrationView.layer.shadowOffset = CGSize.zero
//    registrationView.layer.shadowRadius = 3
  //  registrationView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
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
        
        
    }
    
    //    var address = ""
    //    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
    //         let location = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
    //
    ////        let geoFirestoreRef = Firestore.firestore().collection("my-collection")
    ////        let geoFirestore = GeoFirestore(collectionRef: geoFirestoreRef)
    ////        //GeoFire(firebaseRef: geofireRef)
    ////        geoFire.setLocation(CLLocation(latitude: 37.7853889, longitude: -122.4056973), forKey: "firebase-hq") { (error) in
    ////          if (error != nil) {
    ////            print("An error occured: \(error)")
    ////          } else {
    ////            print("Saved location successfully!")
    ////          }
    ////        }
    //            location.fetchCityAndCountry { city, country, error in
    //                        guard let city = city, let country = country, error == nil else { return }
    //                self.address = "\(city + ", " + country)"
    //                    }
    //
    //
    //    }
    //    func updateUserLocation() {
    //        let db = Firestore.firestore()
    //        let locman = CLLocationManager()
    //        locman.requestWhenInUseAuthorization()
    //        var loc:CLLocation!
    //        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways{
    //            loc = locman.location
    //        }
    //        let lat:Double = loc.coordinate.latitude
    //        let long:Double = loc.coordinate.longitude
    //        let geo = GeoPoint.init(latitude: lat, longitude: long)
    //print("this is my address>>>>",geo)
    //        if let currentUser = Auth.auth().currentUser{
    //
    //            db.collection("users").whereField("uid", isEqualTo: currentUser.uid).setValue(geo, forKey: "address")
    //        }
    //
    //    }
    
    
    let image = UIImage(systemName: "person.fill")
    @IBAction func handleRegister(_ sender: Any) {
        
        let locman = CLLocationManager()
        let authorizationStatus: CLAuthorizationStatus
        
        if #available(iOS 14, *) {
            authorizationStatus = locman.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
        locman.requestWhenInUseAuthorization()
        var loc:CLLocation?
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways{
            loc = locman.location
        }
        if let name = userNameTaxtField.text ,
           let image = image,
           let imageData = image.jpegData(compressionQuality: 0.25),
           let email = userEmailTextField.text ,
           let phoneNumber = userPhoneNumberTextField.text ,
           let password = passWordTextField.text ,
           let loc = loc {
            Auth.auth().createUser(withEmail: email, password: password) { authDataResult, error in
                if let error = error{
                    print(error)
                }
                if let authDataResult = authDataResult {
                    
                    let storageReference = Storage.storage().reference(withPath: "users/\(authDataResult.user.uid)")
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
                                
                                
                                
                                
                                let lat:Double = loc.coordinate.latitude
                                let long:Double = loc.coordinate.longitude
                                let geo = GeoPoint.init(latitude: lat, longitude: long)
                                
                                let dataBase = Firestore.firestore()
                                let userData:[String:Any] = [
                                    "id" : authDataResult.user.uid,
                                    "name" : name,
                                    "email" : email,
                                    "phoneNumber" : phoneNumber,
                                    "userType" : self.isProvider,
                                    "profilePictuer": url.absoluteString,
                                    "service":[],
                                    "address": geo
                                ]
                                
                                dataBase.collection("users").document(authDataResult.user.uid).setData(userData){ error in
                                    if let error = error{
                                        print(error)
                                        
                                    }else{
//
//                                        let number = "+1\(phoneNumber)"
//                                        AuthManager.shared.startAuth(phoneNumber: number) {  success in
//                                            guard success else{return}
//                                            DispatchQueue.main.async {
//                                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//
//                                                    let mainTabBarController = storyboard.instantiateViewController(identifier: "SMSCode")
//                                                    mainTabBarController.modalPresentationStyle = .fullScreen
//
//                                                    self.present(mainTabBarController, animated: true, completion: nil)
//
//
//                                            }
//                                        }
                                        
                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
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
        }
    }
}


extension RegistrationViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
