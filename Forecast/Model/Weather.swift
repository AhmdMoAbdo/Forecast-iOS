//
//  Weather.swift
//  Forecast
//
//  Created by Ahmed on 20/07/2023.
//

import Foundation

struct Weather: Codable {
    let id: Int?
    let main: String?
    let description: String?
    let icon: String?
}
