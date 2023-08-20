//
//  Alert.swift
//  Forecast
//
//  Created by Ahmed on 20/07/2023.
//

import Foundation

struct Alert: Codable {
    let senderName, event: String?
    let start, end: Int?
    let description: String?
    let tags: [String]?

    enum CodingKeys: String, CodingKey {
        case senderName = "sender_name"
        case event, start, end, description, tags
    }
}
