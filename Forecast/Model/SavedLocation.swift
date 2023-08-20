//
//  SavedLocation.swift
//  Forecast
//
//  Created by Ahmed on 23/07/2023.
//

import Foundation
import RealmSwift

class SavedLocation: Object {
    @objc dynamic var lon: String = ""
    @objc dynamic var lat: String = ""
    @objc dynamic var cityName: String = ""
    @objc dynamic var countryName: String = ""
}
