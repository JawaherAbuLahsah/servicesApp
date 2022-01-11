//
//  User.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 22/05/1443 AH.
//

import Foundation
import Firebase
import CoreLocation
struct User {
    var id = ""
    var name = ""
    var email = ""
    var phoneNumber = ""
    var userType = true
    var profilePictuer = ""
    var service = [""]
    var latitude = 0.0
    var longitude = 0.0
    
    init(dict:[String:Any]) {
        if let id = dict["id"] as? String,
           let name = dict["name"] as? String,
           let email = dict["email"] as? String,
           let phoneNumber = dict["phoneNumber"] as? String,
           let userType = dict["userType"] as? Bool,
           let profilePictuer = dict["profilePictuer"] as? String,
           let service = dict["service"] as? [String],
           let latitude = dict["latitude"] as? Double,
           let longitude = dict["longitude"] as? Double{
            self.name = name
            self.id = id
            self.email = email
            self.phoneNumber = phoneNumber
            self.userType = userType
            self.profilePictuer = profilePictuer
            self.service = service
            self.latitude = latitude
            self.longitude = longitude
            
        }
    }
    var location: CLLocation {
        return CLLocation(latitude: self.latitude, longitude: self.longitude)
    }

    func distance(to location: CLLocation) -> CLLocationDistance {
        return location.distance(from: self.location)
    }
}
