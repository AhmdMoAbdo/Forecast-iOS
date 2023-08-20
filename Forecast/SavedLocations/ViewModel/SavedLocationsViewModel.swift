//
//  SavedLocationsViewModel.swift
//  Forecast
//
//  Created by Ahmed on 05/08/2023.
//

import Foundation

class SavedLocationsViewModel{
    
    var localSource: LocalSource!
    var savedLocations: [SavedLocation] = []
    var doneGettingSavedLocations: ()->() = {}
    
    init(localSource: LocalSource!) {
        self.localSource = localSource
    }
    
    func getSavedLocations(){
        savedLocations = localSource.getSavedLocations()
        doneGettingSavedLocations()
    }
    
    func addNewLocation(locationToAdd: SavedLocation){
        localSource.addNewLocation(locationToAdd: locationToAdd)
    }
    
    func deleteLocation(locationToDelete: SavedLocation){
        localSource.deleteLocation(locationToDelete: locationToDelete)
    }
    
    func checkIfLocationIsNew(locationInQuestion: SavedLocation) -> Bool{
        return localSource.checkIfLocationIsNew(locationInQuestion: locationInQuestion)
    }
}
