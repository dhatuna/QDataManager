//
//  File.swift
//  QDataManager
//
//  Created by Junkyu Jeon on 2/13/25.
//

import Foundation

struct QTestDataStruct: Codable {
    let created: Date?
    let identifier: Int?
    let intValue: Int?
    let strValue: String?
}

struct QTestSubdataStruct: Codable {
    let created: Date?
    let identifier: Int?
    let type: String?
    let type2: String?
    let moreData: Dictionary<String, AnyCodable>?
}
