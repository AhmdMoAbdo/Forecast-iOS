//
//  SavedAlert.swift
//  Forecast
//
//  Created by Ahmed on 05/08/2023.
//

import Foundation
import RealmSwift

class SavedAlert: Object{
    @objc dynamic var lon: String = ""
    @objc dynamic var lat: String = ""
    @objc dynamic var locationName: String = ""
    @objc dynamic var date: Date = Date()
}
