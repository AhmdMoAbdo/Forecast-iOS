//
//  HomeViewModel.swift
//  Forecast
//
//  Created by Ahmed on 20/07/2023.
//

import Foundation

class HomeViewModel{
    
    let network:ApiService!
    
    init(network: ApiService!) {
        self.network = network
    }
    
    func getHomeData(lat: String,lon: String,completionHandler:@escaping (Forecast)->Void){
        network.getWeatherData(lat: lat, lon: lon,language: UserDefaultsManger.userDefaultHandler.getLanguage()) { forcast in
            guard let forecast = forcast else {
                return
            }
            completionHandler(forecast)
        }
    }
}
