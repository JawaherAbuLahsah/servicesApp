//
//  CLLocation.swift
//  ServicesApp
//
//  Created by Jawaher Mohammad on 27/05/1443 AH.
//

import Foundation
import CoreLocation
extension CLLocation {
    func fetchCityAndCountry(completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first?.locality, $0?.first?.country, $1) }
    }
}