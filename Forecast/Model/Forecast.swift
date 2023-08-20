//
//  Forecast.swift
//  Forecast
//
//  Created by Ahmed on 20/07/2023.
//

import Foundation

struct Forecast: Codable {
    let lat, lon: Double?
    let timezone: String?
    let timezoneOffset: Int?
    let current: Current?
    let hourly: [Current]?
    let daily: [Daily]?
    let alerts: [Alert]?

    enum CodingKeys: String, CodingKey {
        case lat, lon, timezone
        case timezoneOffset = "timezone_offset"
        case current, hourly, daily, alerts
    }
}
