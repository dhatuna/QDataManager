//
//  File.swift
//  QDataManager
//
//  Created by Junkyu Jeon on 2/13/25.
//

import Foundation

extension Encodable {
    func toDictionary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any]
    }
}

extension Dictionary where Key == String, Value == AnyCodable {
    func toAnyDictionary() -> [String: Any] {
        return self.mapValues { $0.value }
    }
}
