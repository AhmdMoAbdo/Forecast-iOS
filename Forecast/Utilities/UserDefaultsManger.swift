//
//  UserDefaultsManger.swift
//  Forecast
//
//  Created by Ahmed on 29/07/2023.
//

import Foundation
import CoreLocation

class UserDefaultsManger{
    
    let userDefaultsManger = UserDefaults()
    static let userDefaultHandler = UserDefaultsManger()
    
    private init(){}
    
    func saveLocationMethod(method: LocationMethod){
        userDefaultsManger.set(method.rawValue, forKey: UDConstants.location)
    }
    
    func getLocaionMethod() -> String {
        return userDefaultsManger.string(forKey: UDConstants.location) ?? LocationMethod.gps.rawValue
    }
    
    func saveTemperatureUnit(unit: TemperatureUnit){
        userDefaultsManger.set(unit.rawValue, forKey: UDConstants.temperature)
    }
    
    func getTemperatureUnit() -> String {
        userDefaultsManger.string(forKey: UDConstants.temperature) ?? TemperatureUnit.cel.rawValue
    }
    
    func saveSpeedUnit(unit: SpeedUnit){
        userDefaultsManger.set(unit.rawValue, forKey: UDConstants.speed)
    }
    
    func getSpeedUnit() -> String{
        userDefaultsManger.string(forKey: UDConstants.speed) ?? SpeedUnit.mps.rawValue
    }
    
    func saveLanguage(language: LanguageType){
        userDefaultsManger.set(language.rawValue, forKey: UDConstants.language)
    }
    
    func getLanguage() -> String{
        userDefaultsManger.string(forKey: UDConstants.language) ?? LanguageType.en.rawValue
    }
    
    func saveAlertMethod(method: AlertMehod){
        userDefaultsManger.set(method.rawValue, forKey: UDConstants.alert)
    }
    
    func getAlertMethod() -> String{
        userDefaultsManger.string(forKey: UDConstants.alert) ?? AlertMehod.alarm.rawValue
    }
    
    func confirmFirstTimeDone(){
        userDefaultsManger.set(UDConstants.notFirst, forKey: UDConstants.state)
    }
    
    func checkIfFirrstTime() -> Bool {
        if userDefaultsManger.string(forKey: UDConstants.state) ?? "" == "" {
            return true
        }else {
            return false
        }
    }
    
    func saveMapLocation(location: CLLocationCoordinate2D){
        userDefaultsManger.set(String(location.latitude) , forKey: UDConstants.lat)
        userDefaultsManger.set(String(location.longitude) , forKey: UDConstants.lon)
    }
    
    func getMapLocaiton() -> (String,String) {
        return (userDefaultsManger.string(forKey: UDConstants.lat) ?? "30.0444" , userDefaultsManger.string(forKey: UDConstants.lon) ?? "31.2357")
    }
    
    class UDConstants{
        static let location = "Location"
        static let temperature = "temperature"
        static let speed = "speed"
        static let language = "language"
        static let alert = "alert"
        static let state = "state"
        static let notFirst = "notFirst"
        static let lat = "lat"
        static let lon = "lon"
    }
}

enum LocationMethod: String {
    case gps = "gps"
    case map = "map"
}

enum TemperatureUnit: String {
    case kel = "K"
    case feh = "F"
    case cel = "C"
}

enum LanguageType: String {
    case ar = "ar"
    case en = "en"
}

enum SpeedUnit: String {
    case mph = "mph"
    case mps = "mps"
}

enum AlertMehod: String {
    case alarm = "alarm"
    case notification = "notification"
}
