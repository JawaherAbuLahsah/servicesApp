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
    var createAt : Timestamp?
    var user : User
    var service : Service
    
    init(dict:[String:Any],id:String,user:User,service:Service){
        if let title = dict["title"] as? String,
           let details = dict["details"] as? String,
           let createAt = dict["createAt"] as? Timestamp {
            self.title = title
            self.details = details
            self.createAt = createAt
        }
        self.id = id
        self.user = user
        self.service = service
    }
}
