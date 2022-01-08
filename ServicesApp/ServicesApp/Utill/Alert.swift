//
//  Alert.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 03/06/1443 AH.
//

import Foundation
import UIKit
struct Alert{
    static var alert = UIAlertController()
    static func showAlertError(_ messageOnAlart:String){
        alert = UIAlertController(title: "ERROR", message: messageOnAlart, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "cancel", style: .cancel) { Action in
        }
        alert.addAction(alertAction)
    }
}
