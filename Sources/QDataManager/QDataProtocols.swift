//
//  File.swift
//  QDataManager
//
//  Created by Junkyu Jeon on 2/2/25.
//

import Foundation

public protocol QDataDecodableProperty: AnyObject, Decodable {
    associatedtype ValueType: Codable
    var wrappedValue: ValueType? { get set }
    func decode(from aDecoder: NSCoder)
}

public protocol QDataEncodableProperty: AnyObject, Encodable {
    associatedtype ValueType: Codable
    var wrappedValue: ValueType? { get set }
    func encode(to aCoder: NSCoder)
}
