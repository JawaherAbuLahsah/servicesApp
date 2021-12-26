//
//  ChangeLanguage.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 21/05/1443 AH.
//

import Foundation

extension String{
    var localizes:String{
        return NSLocalizedString(self, tableName: "Localization", bundle: .main, value: self, comment: self)
    }
}
