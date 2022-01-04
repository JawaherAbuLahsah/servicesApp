//
//  RequestDetailsViewController.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 22/05/1443 AH.
//

import UIKit
import MapKit
import Firebase
class RequestDetailsViewController: UIViewController {
    
    @IBOutlet weak var serviceNameLabel: UILabel!
    var selectServices : Service?
    
    @IBOutlet weak var chooseLocationButton: UIButton!
    
    @IBOutlet weak var currentLocationButton: UIButton!
    
    @IBOutlet weak var showMapButton: UIButton!
    
    @IBOutlet weak var removeAnnotationButton: UIButton!{
        didSet{
           //  removeAnnotationButton.isHidden = true
        }
    }
    @IBOutlet weak var mapView: MKMapView!{
        didSet{
            //mapView.isHidden = true
            let gestureRecognizer = UITapGestureRecognizer(
                target: self, action:#selector(handleTap))
            gestureRecognizer.delegate = self
            mapView.addGestureRecognizer(gestureRecognizer)
        }
    }
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
    override func viewDidLoad() {
        super.viewDidLoad()
        if let selectServices = selectServices{
            serviceNameLabel.text = selectServices.name
        }
        
    }
    
    @IBAction func sendRequest(_ sender: Any) {
        if let title = requestTitleTextField.text,
           let details = requestDetailsTextView.text ,
           let currentUser = Auth.auth().currentUser {
            let requestId = "\(Firebase.UUID())"
            let dataBase = Firestore.firestore()
            if let selectServices = selectServices {
                
                let requestData :[String:Any] = [
                    "requestsId" : currentUser.uid,
                    "providerId" :"0",
                    "title" : title,
                    "details" : details,
                    "price": "0",
                    "createAt" : FieldValue.serverTimestamp(),
                    "haveProvider": false,
                    "serviceId":selectServices.id
                ]
                dataBase.collection("requests").document(requestId).setData(requestData){ error in
                    if let error = error {
                        print(error)
                    }
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func tapDone() {
        self.view.endEditing(true)
    }
    
    
    @IBAction func removeAnnotation(_ sender: Any) {
        
        let annotations = mapView.annotations.filter({ !($0 is MKUserLocation) })
        mapView.removeAnnotations(annotations)
        
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
        let lat:Double = annotation.coordinate.latitude
        let long:Double = annotation.coordinate.longitude
        let geo = GeoPoint(latitude: lat, longitude: long)
        
    }
}
