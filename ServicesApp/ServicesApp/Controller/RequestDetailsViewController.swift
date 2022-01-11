//
//  RequestDetailsViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 22/05/1443 AH.
//

import UIKit
import Firebase
import CoreLocation
import MapKit
class RequestDetailsViewController: UIViewController ,CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    @IBOutlet weak var serviceNameLabel: UILabel!
    var selectServices : Service?
    
    @IBOutlet weak var titleLabel: UILabel!{
        didSet{
            titleLabel.text = "title".localizes
        }
    }
    @IBOutlet weak var detailsLabel: UILabel!{
        didSet{
            detailsLabel.text = "details".localizes
        }
    }
    @IBOutlet weak var sendButton: UIButton!{
        didSet{
            sendButton.setTitle("send".localizes, for: .normal)
        }
    }
    
    @IBOutlet weak var requestTitleTextField: UITextField!{
        didSet{
            requestTitleTextField.delegate = self
            requestTitleTextField.placeholder = "title".localizes
        }
    }
    @IBOutlet weak var requestDetailsTextView: UITextView!{
        didSet{
            let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 44.0))
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: #selector(tapDone))
            toolBar.setItems([flexibleSpace, doneButton], animated: false)
            requestDetailsTextView.inputAccessoryView = toolBar
            //            requestDetailsTextView.toolbarPlaceholder = "details".localizes
            
        }
    }
    
    
    
    @IBOutlet weak var showMapButton: UIButton!
    
    @IBOutlet weak var removeAnnotationButton: UIButton!{
        didSet{
            removeAnnotationButton.isHidden = true
        }
    }
    
    @IBOutlet weak var mapView: MKMapView!{
    didSet{
            mapView.isHidden = true
            let gestureRecognizer = UITapGestureRecognizer(
                target: self, action:#selector(handleTap))
            gestureRecognizer.delegate = self
            mapView.addGestureRecognizer(gestureRecognizer)
        }
    }
    
    var isShow = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let selectServices = selectServices{
            serviceNameLabel.text = selectServices.name
        }
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    var latitude = 0.0
    var longitude = 0.0
    //    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //            let locValue:CLLocationCoordinate2D = manager.location!.coordinate
    //        latitude = locValue.latitude
    //        longitude = locValue.longitude
    //    }
    @IBAction func sendRequest(_ sender: Any) {
        if let title = requestTitleTextField.text,
           let details = requestDetailsTextView.text ,
           let currentUser = Auth.auth().currentUser {
            let requestId = "\(Firebase.UUID())"
            let dataBase = Firestore.firestore()
            
            dataBase.collection("users").document(currentUser.uid).getDocument { documentSnapshot, error in
                if let error = error{
                    print(error)
                }
                if let documentSnapshot = documentSnapshot,
                   let userData = documentSnapshot.data(){
                    let user = User(dict: userData)
                    if let selectServices = self.selectServices {
                        let requestData :[String:Any]
                        if self.latitude == 0.0 && self.longitude == 0.0 {
                            requestData = [
                                "requestsId" : currentUser.uid,
                                "providerId" :"0",
                                "title" : title,
                                "details" : details,
                                "price": "0",
                                "createAt" : FieldValue.serverTimestamp(),
                                "haveProvider": false,
                                "serviceId":selectServices.id,
                                "latitude" : user.latitude,
                                "longitude" : user.longitude
                            ]
                        }else{
                            requestData = [
                                "requestsId" : currentUser.uid,
                                "providerId" :"0",
                                "title" : title,
                                "details" : details,
                                "price": "0",
                                "createAt" : FieldValue.serverTimestamp(),
                                "haveProvider": false,
                                "serviceId":selectServices.id,
                                "latitude" : self.latitude,
                                "longitude" : self.longitude
                            ]
                        }
                        dataBase.collection("requests").document(requestId).setData(requestData){ error in
                            if let error = error {
                                print(error)
                            }
                        }
                    }
                }
            }
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(identifier: "ServiceRequesterNavigationController")
        mainTabBarController.modalPresentationStyle = .fullScreen
        self.present(mainTabBarController, animated: true, completion: nil)
    }
    
    
    @objc func tapDone() {
        self.view.endEditing(true)
    }
    
    
    @IBAction func removeAnnotation(_ sender: Any) {
        
        let annotations = mapView.annotations.filter({ !($0 is MKUserLocation) })
        mapView.removeAnnotations(annotations)
        
    }
    
    
    @IBAction func showMap(_ sender: Any) {
        if isShow{
            removeAnnotationButton.isHidden = false
            mapView.isHidden = false
            isShow = false
        }else{
            removeAnnotationButton.isHidden = true
            mapView.isHidden = true
            isShow = true
        }
    }
    
    
}

extension RequestDetailsViewController:UITextFieldDelegate,UITextViewDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
}

extension RequestDetailsViewController:MKMapViewDelegate, UIGestureRecognizerDelegate{
    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        latitude = annotation.coordinate.latitude
        longitude = annotation.coordinate.longitude
        
    }
}
