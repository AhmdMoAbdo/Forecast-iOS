//
//  RealmManger.swift
//  Forecast
//
//  Created by Ahmed on 05/08/2023.
//

import Foundation
import RealmSwift

class RealmManger{
    
    static var realmHandler = RealmManger()
    var db: Realm!
    
    private init() {
        try! db = Realm()
    }
    
    func getSavedLocations() -> [SavedLocation]{
        var arr: [SavedLocation] = []
        let savedLocations = db.objects(SavedLocation.self)
        for item in savedLocations{
            arr.append(item)
        }
        return arr
    }
    
    func addNewLocation(locationToAdd: SavedLocation){
        do{
            try! db.write {
                db.add(locationToAdd)
            }
        }
    }
    
    func deleteLocation(locationToDelete: SavedLocation){
        do{
            try! db.write({
                db.delete(locationToDelete)
            })
        }
    }
    
    func checkIfLocationIsNew(locationInQuestion: SavedLocation) -> Bool{
        let loctionsArr = db.objects(SavedLocation.self).where { $0.cityName == locationInQuestion.cityName && $0.countryName == locationInQuestion.countryName }
        if loctionsArr.isEmpty {
            return true
        }else{
            return false
        }
    }
    
    func getAllAlerts() -> [SavedAlert]{
        var arr: [SavedAlert] = []
        let savedAlerts = db.objects(SavedAlert.self)
        for item in savedAlerts{
            arr.append(item)
        }
        return arr
    }
    
    func addNewAlert(alertToAdd: SavedAlert){
        do{
            try! db.write({
                db.add(alertToAdd)
            })
        }
    }
    
    func deleteAlert(alertToDelete: SavedAlert){
        do{
            try! db.write({
                db.delete(alertToDelete)
            })
        }
    }
    
    func checkIfAlertIsNew(alertInQuestion: SavedAlert) -> Bool{
        let alertsArr = db.objects(SavedAlert.self).where { $0.date == alertInQuestion.date && $0.locationName == alertInQuestion.locationName }
        if alertsArr.isEmpty {
            return true
        }else{
            return false
        }
    }
    
}
