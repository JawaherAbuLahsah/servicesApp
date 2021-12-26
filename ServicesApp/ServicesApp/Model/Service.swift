//
//  Service.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 22/05/1443 AH.
//

import Foundation
struct Service{
    var id = ""
    var name = ""
    init(dict:[String:Any]){
        if let id = dict["id"] as? String,
           let name = dict["name"] as? String{
            self.id = id
            self.name = name
        }
    }
}
