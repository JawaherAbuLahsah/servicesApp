//
//  RequestsViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 19/06/1443 AH.
//

import UIKit
import Firebase
import MaterialComponents
import MapKit
import CoreLocation
import IQKeyboardManagerSwift
class RequestsViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var requestView: UIView!{
        didSet{
            requestView.layer.cornerRadius = 10
            requestView.layer.shadowRadius = 30
            requestView.layer.shadowOpacity = 0.5
        }
    }
    @IBOutlet weak var sendButton: UIButton!{
        didSet{
            sendButton.setTitle("send".localizes, for: .normal)
            sendButton.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var priceTextField: MDCOutlinedTextField!{
        didSet{
            priceTextField.label.text = "price".localizes
        }
    }
    @IBOutlet weak var titleRequestLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var requseterLabel: UILabel!
    
    
    var selectedRequest:Request?
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //dismiss the keyboard when pressing outside
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        if let coor = mapView.userLocation.location?.coordinate{
            mapView.setCenter(coor, animated: true)
        }
        
        if let selectedRequest = selectedRequest {
            CLGeocoder().reverseGeocodeLocation(selectedRequest.location) { placemarks, error in
                
                guard let placemark = placemarks?.first else {
                    let errorString = error?.localizedDescription ?? "Unexpected Error"
                    print("Unable to reverse geocode the given location. Error: \(errorString)")
                    return
                }
                
                let reversedGeoLocation = ReversedGeoLocation(with: placemark)
                self.locationLabel.text = "location".localizes+": "+reversedGeoLocation.formattedAddress
                
                self.titleRequestLabel.text = selectedRequest.title
                self.detailsLabel.text = "details".localizes+": "+selectedRequest.details
                self.requseterLabel.text = "from".localizes+": "+selectedRequest.userRequest.name
                
                let location = CLLocationCoordinate2D(latitude: selectedRequest.latitude , longitude: selectedRequest.longitude)
                self.mapView.setCenter(location, animated: true)
                let pin = MKPointAnnotation()
                pin.coordinate = location
                pin.title = reversedGeoLocation.formattedAddress
                self.mapView.addAnnotation(pin)
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
     }

     @objc func keyboardWillShow(sender: NSNotification) {
          self.view.frame.origin.y = -100 // Move view 150 points upward
     }

     @objc func keyboardWillHide(sender: NSNotification) {
          self.view.frame.origin.y = 0 // Move view to original position
     }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate

        mapView.mapType = MKMapType.hybrid

        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: locValue, span: span)
        mapView.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
    }
    
    @IBAction func send(_ sender: Any) {
        if let selectedRequest = selectedRequest , let price = priceTextField.text {
            if price != "" {
            let db = Firestore.firestore()
            let ref = db.collection("requests")
            let priceData:[String:Any] = ["price": price,
                                          "requestsId" :selectedRequest.userRequest.id,
                                          "providerId":selectedRequest.userProvider.id,
                                          "title" : selectedRequest.title ,
                                          "details" : selectedRequest.details ,
                                          "createAt" : FieldValue.serverTimestamp(),
                                          "haveProvider":true,
                                          "serviceId":selectedRequest.requestType.id,
                                          "latitude" : selectedRequest.latitude,
                                          "longitude" : selectedRequest.longitude,
                                          "accept" : false,
                                          "done" : false
            ]
            
            ref.document(selectedRequest.id).setData(priceData) { error in
                if let error = error {
                    print("FireStore Error",error.localizedDescription)
                }
            }
                self.dismiss(animated: true, completion: nil)
        
       
        }else{
            Alert.showAlertError("check".localizes)
            self.present(Alert.alert, animated: true, completion: nil)
        }
        }
    }
    
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
