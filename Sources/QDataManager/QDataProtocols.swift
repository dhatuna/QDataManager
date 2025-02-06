//
//  File.swift
//  QDataManager
//
//  Created by Junkyu Jeon on 2/2/25.
//

import Foundation

//public protocol QDataDecodableProperty: AnyObject, Decodable {
//    associatedtype ValueType: Codable
//    var wrappedValue: ValueType? { get set }
//    func decode(from aDecoder: NSCoder)
//}
//
//public protocol QDataEncodableProperty: AnyObject, Encodable {
//    associatedtype ValueType: Codable
//    var wrappedValue: ValueType? { get set }
//    func encode(to aCoder: NSCoder)
//}
//
//public protocol QDataPropertyProtocol: QDataEncodableProperty, QDataDecodableProperty {
//    func resetValue()
//}


public protocol QDataPropertyProtocol {
    /// NSCoding 기반으로 인코딩할 때 호출됨.
    func encode(to aCoder: NSCoder)
    /// NSCoding 기반으로 디코딩할 때 호출됨.
    func decode(from aDecoder: NSCoder)
    /// 프로퍼티의 wrappedValue를 defaultValue로 리셋합니다.
    func resetValue()
}
