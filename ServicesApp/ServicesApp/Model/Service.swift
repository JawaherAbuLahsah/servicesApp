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
           let arName = dict["arName"] as? String,
               let enName = dict["enName"] as? String{
            self.id = id
            if UserDefaults.standard.object(forKey: "currentLanguage") as? String == "ar"{
            self.name = arName
            }else{
            self.name = enName
            }
        }
    }
}
