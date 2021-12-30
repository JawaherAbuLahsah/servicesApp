//
//  Request.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 22/05/1443 AH.
//

import Foundation
import Firebase
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
    //var service : Service
    
    init(dict:[String:Any],id:String,userRequest:User,userProvider:User,requestType :Service){
        if let title = dict["title"] as? String,
           let details = dict["details"] as? String,
           let price = dict["price"] as? String,
           let haveProvider = dict["haveProvider"] as? Bool,
           let createAt = dict["createAt"] as? Timestamp {
            self.title = title
            self.details = details
            self.price = price
            self.createAt = createAt
            self.haveProvider = haveProvider
        }
        self.id = id
        self.userRequest = userRequest
        self.userProvider = userProvider
        self.requestType = requestType
    }
}
