//
//  User.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 22/05/1443 AH.
//

import Foundation
struct User {
    var id = ""
    var name = ""
    var email = ""
    var phoneNumber = 0
    var userType = true
    var profilePictuer = ""

    init(dict:[String:Any]) {
        if let id = dict["id"] as? String,
           let name = dict["name"] as? String,
           let email = dict["email"] as? String,
           let phoneNumber = dict["phoneNumber"] as? Int,
           let userType = dict["userType"] as? Bool,
           let profilePictuer = dict["profilePictuer"] as? String{
            self.name = name
            self.id = id
            self.email = email
            self.phoneNumber = phoneNumber
            self.userType = userType
            self.profilePictuer = profilePictuer
        }
    }
}
