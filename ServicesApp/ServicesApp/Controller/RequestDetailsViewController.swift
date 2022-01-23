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
import LottieCore
class RequestDetailsViewController: UIViewController ,CLLocationManagerDelegate {
    // MARK: - Outlet
//    @IBOutlet weak var animatiomMapVirw: AnimationView!
        
    
    
    @IBOutlet weak var serviceNameLabel: UILabel!
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
        }
    }
    @IBOutlet weak var showMapButton: UIButton!{
        didSet{
            showMapButton.setTitle("show".localizes, for: .normal)
        }
    }
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
    
    // MARK: - Definitions
    var selectServices : Service?
    let locationManager = CLLocationManager()
    var isShow = true
    var latitude = 0.0
    var longitude = 0.0
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
//        let animatiomMapView = AnimationView(name: "map")
//
//        animatiomMapView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
//
//        animatiomMapView.loopMode = .loop
//        animatiomMapVirw.addSubview(animatiomMapView)
//        animatiomMapView.play()
//
//        if let selectServices = selectServices{
//            serviceNameLabel.text = selectServices.name
//        }
//
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        if let coor = mapView.userLocation.location?.coordinate{
            mapView.setCenter(coor, animated: true)
        }
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - Function to get the current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        mapView.mapType = MKMapType.standard
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: locValue, span: span)
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = locValue
        mapView.addAnnotation(annotation)
        
        locationManager.stopUpdatingLocation()
        latitude = manager.location!.coordinate.latitude
        longitude = manager.location!.coordinate.longitude
    }
    
    
    // MARK: - Function to create request
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
                                "longitude" : user.longitude,
                                "accept" : false,
                                "done" : false
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
                                "longitude" : self.longitude,
                                "accept" : false,
                                "done" : false
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
    
    // MARK: - Done action
    @objc func tapDone() {
        self.view.endEditing(true)
    }
    
    // MARK: - Function to remove annotation
    @IBAction func removeAnnotation(_ sender: Any) {
        
        let annotations = mapView.annotations.filter({ !($0 is MKUserLocation) })
        mapView.removeAnnotations(annotations)
        latitude = 0.0
        longitude = 0.0
        
    }
    
    // MARK: - Function to show map
    @IBAction func showMap(_ sender: Any) {
        if isShow{
            removeAnnotationButton.isHidden = false
//            animatiomMapVirw.isHidden = true
            mapView.isHidden = false
            isShow = false
        }else{
            removeAnnotationButton.isHidden = true
//            animatiomMapVirw.isHidden = false
            mapView.isHidden = true
            isShow = true
        }
    }
}

// MARK: - Extenstion
extension RequestDetailsViewController:UITextFieldDelegate,UITextViewDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
}
// MARK: - Extenstion
extension RequestDetailsViewController:MKMapViewDelegate, UIGestureRecognizerDelegate{
    // for put annotation to get location
    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        locationManager.stopUpdatingLocation()
        let annotations = mapView.annotations.filter({ !($0 is MKUserLocation) })
        mapView.removeAnnotations(annotations)
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        latitude = annotation.coordinate.latitude
        longitude = annotation.coordinate.longitude
        
    }
}
