//
//  AlertsViewModel.swift
//  Forecast
//
//  Created by Ahmed on 04/08/2023.
//

import Foundation

class AlertsViewModel{
    
    var network: ApiService!
    var localSource: LocalSource!
    var savedAlerts: [SavedAlert] = []
    var doneGettingAlerts: ()->() = {}
    
    init(network: ApiService!, localSource: LocalSource!) {
        self.network = network
        self.localSource = localSource
    }
    
    func getAlertData(lat: String,lon: String,completionHandler:@escaping (Forecast)->Void){
        network.getWeatherData(lat: lat, lon: lon,language: UserDefaultsManger.userDefaultHandler.getLanguage()) { forcast in
            guard let forecast = forcast else {
                return
            }
            completionHandler(forecast)
        }
    }
    
    func getSavedAlerts(){
        let currentAlertsInDB = localSource.getAllAlerts()
        var alertsToDisplay: [SavedAlert] = []
        for alert in currentAlertsInDB {
            if alert.date < Date(){
                deleteAlert(alertToBeDeleted: alert)
            }else{
                alertsToDisplay.append(alert)
            }
        }
        savedAlerts = alertsToDisplay
        doneGettingAlerts()
    }
    
    func addAnotherAlert(alertToBeAdded: SavedAlert){
        localSource.addNewAlert(alertToAdd: alertToBeAdded)
    }
    
    func deleteAlert(alertToBeDeleted: SavedAlert){
        localSource.deleteAlert(alertToDelete: alertToBeDeleted)
    }
    
    func checkIfAlertIsNew(alertInQuestion: SavedAlert) -> Bool{
        return localSource.checkIfAlertIsNew(alertInQuestion: alertInQuestion)
    }
}
