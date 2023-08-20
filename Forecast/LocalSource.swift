//
//  LocalSource.swift
//  Forecast
//
//  Created by Ahmed on 05/08/2023.
//

import Foundation

protocol LocalSource{
    func getSavedLocations() -> [SavedLocation]
    func addNewLocation(locationToAdd: SavedLocation)
    func deleteLocation(locationToDelete: SavedLocation)
    func checkIfLocationIsNew(locationInQuestion: SavedLocation) -> Bool
    func getAllAlerts() -> [SavedAlert]
    func addNewAlert(alertToAdd: SavedAlert)
    func deleteAlert(alertToDelete: SavedAlert)
    func checkIfAlertIsNew(alertInQuestion: SavedAlert) -> Bool
}

class ConcreteLocalSource: LocalSource{
    
    func getSavedLocations() -> [SavedLocation]{
        return RealmManger.realmHandler.getSavedLocations()
    }
    
    func addNewLocation(locationToAdd: SavedLocation){
        RealmManger.realmHandler.addNewLocation(locationToAdd: locationToAdd)
    }
    
    func deleteLocation(locationToDelete: SavedLocation){
        RealmManger.realmHandler.deleteLocation(locationToDelete: locationToDelete)
    }
    
    func checkIfLocationIsNew(locationInQuestion: SavedLocation) -> Bool{
        return RealmManger.realmHandler.checkIfLocationIsNew(locationInQuestion: locationInQuestion)
    }
    
    func getAllAlerts() -> [SavedAlert]{
        return RealmManger.realmHandler.getAllAlerts()
    }
    
    func addNewAlert(alertToAdd: SavedAlert){
        RealmManger.realmHandler.addNewAlert(alertToAdd: alertToAdd)
    }
    
    func deleteAlert(alertToDelete: SavedAlert){
        RealmManger.realmHandler.deleteAlert(alertToDelete: alertToDelete)
    }
    
    func checkIfAlertIsNew(alertInQuestion: SavedAlert) -> Bool{
        return RealmManger.realmHandler.checkIfAlertIsNew(alertInQuestion: alertInQuestion)
    }
}
