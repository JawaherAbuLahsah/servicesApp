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
    var user : User
    //var service : Service
    
    init(dict:[String:Any],id:String,user:User){
        if let title = dict["title"] as? String,
           let details = dict["details"] as? String,
           let price = dict["price"] as? String,
           let createAt = dict["createAt"] as? Timestamp {
            self.title = title
            self.details = details
            self.price = price
            self.createAt = createAt
        }
        self.id = id
        self.user = user
    
    }
}
