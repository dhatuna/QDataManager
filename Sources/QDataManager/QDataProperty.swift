//
//  QDataProperty.swift
//  QDataManager
//
//  Created by Junkyu Jeon on 2/2/25.
//

import Foundation

@propertyWrapper
public class QDataProperty<T: Codable>: QDataEncodableProperty, QDataDecodableProperty {
//    private var value: T?
//    let key: String
//    
//    var wrappedValue: T? {
//        get { value }
//        set { value = newValue}
//    }
    public var wrappedValue: T?
    public let key: String
    
    init(_ key: String) {
        self.key = key
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.wrappedValue = try? container.decode(T.self)
        self.key = ""
    }

    public func encode(to aCoder: NSCoder) {
        guard let wrappedValue = wrappedValue else { return }
        
        do {
            let encodedData = try JSONEncoder().encode(wrappedValue)
            aCoder.encode(encodedData, forKey: key)
        } catch {
            Debugger.printd("❌ Encoding error for key '\(key)': \(error)")
        }
    }
    
    public func decode(from aDecoder: NSCoder) {
        if let data = aDecoder.decodeObject(of: NSData.self, forKey: key) as? Data {
            do {
                self.wrappedValue = try JSONDecoder().decode(T.self, from: data)
            } catch {
                Debugger.printd("❌ Decoding error for key '\(key)': \(error)")
            }
        }
    }
}
