//
//  Request.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 22/05/1443 AH.
//

import Foundation
import Firebase
import CoreLocation
struct Request{
    var id = ""
    var title = ""
    var details = ""
    var price = ""
    var createAt : Timestamp?
    var userProvider : User
    var userRequest:User
    var haveProvider = false
    var requestType :Service
    var latitude = 0.0
    var longitude = 0.0
    var accept = false
    
    init(dict:[String:Any],id:String,userRequest:User,userProvider:User,requestType :Service){
        if let title = dict["title"] as? String,
           let details = dict["details"] as? String,
           let price = dict["price"] as? String,
           let haveProvider = dict["haveProvider"] as? Bool,
           let createAt = dict["createAt"] as? Timestamp ,
           let latitude = dict["latitude"] as? Double,
           let longitude = dict["longitude"] as? Double,
           let accept = dict["accept"] as? Bool{
            self.title = title
            self.details = details
            self.price = price
            self.createAt = createAt
            self.haveProvider = haveProvider
            self.latitude = latitude
            self.longitude = longitude
            self.accept = accept
           
        }
        self.id = id
        self.userRequest = userRequest
        self.userProvider = userProvider
        self.requestType = requestType
    }
    var location: CLLocation {
        return CLLocation(latitude: self.latitude, longitude: self.longitude)
    }

    func distance(to location: CLLocation) -> CLLocationDistance {
        return location.distance(from: self.location)
    }
}
