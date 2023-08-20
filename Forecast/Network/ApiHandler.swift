//
//  ApiHandler.swift
//  Forecast
//
//  Created by Ahmed on 20/07/2023.
//

import Foundation
import Alamofire

protocol ApiService{
    func getWeatherData(lat: String, lon:String, language:String, completionHandler:@escaping (Forecast?)->Void)
}

class ApiHandler: ApiService{
    
    func getWeatherData(lat: String, lon:String, language:String, completionHandler:@escaping (Forecast?)->Void){
        let url = "https://api.openweathermap.org/data/3.0/onecall?lat=\(lat)&lon=\(lon)&exclude=minutely&units=metric&lang=\(language)&appid=353e9f9e5836cd2d31eafe8c6be06294"
        AF.request(url,method: .get).response { response in
            switch response.result{
            case .success(let data):
                do{
                    let respnse = try JSONDecoder().decode(Forecast.self, from: data ?? Data())
                    completionHandler(respnse)
                }catch let error{
                    completionHandler(nil)
                    print(error.localizedDescription)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
