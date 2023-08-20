//
//  Temp.swift
//  Forecast
//
//  Created by Ahmed on 20/07/2023.
//

import Foundation

struct Temp: Codable {
    let day, min, max, night: Double?
    let eve, morn: Double?
}
