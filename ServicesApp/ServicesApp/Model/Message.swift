//
//  Message.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 28/05/1443 AH.
//

import Foundation
struct Message{
    var id = ""
    var message = ""
    var userId : User
    init(dict:[String:Any],userId : User) {
        if let id = dict["id"] as? String,
           let message = dict["message"] as? String{
            self.id = id
            self.message = message
        }
        self.userId = userId
    }
}
