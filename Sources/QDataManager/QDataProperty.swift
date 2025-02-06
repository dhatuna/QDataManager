//
//  QDataProperty.swift
//  QDataManager
//
//  Created by Junkyu Jeon on 2/2/25.
//

import Foundation

@propertyWrapper
public final class QDataProperty<T>: QDataPropertyProtocol {
    private enum CodingKeys: String, CodingKey {
        case wrappedValue
        case key
        case defaultValue
    }

    public var wrappedValue: T?
    public let key: String
    public let defaultValue: T?
    
    public init(_ key: String, defaultValue: T? = nil) {
        self.key = key
        self.defaultValue = defaultValue
    }

    public func encode(to aCoder: NSCoder) {
        guard let value = wrappedValue else { return }
        
        if let arrayValue = value as? [Any] {
            let nsArray = arrayValue as NSArray
            aCoder.encode(nsArray, forKey: key)
            return
        } else if let dictValue = value as? [AnyHashable: Any] {
            let nsDict = dictValue as NSDictionary
            aCoder.encode(nsDict, forKey: key)
        } else if let secureValue = value as? NSSecureCoding {
            aCoder.encode(secureValue, forKey: key)
        } else if let codableValue = value as? Encodable {
            do {
                let data = try JSONEncoder().encode(QDataAnyEncodable(codableValue))
                aCoder.encode(data, forKey: key)
            } catch {
                Debugger.printd("❌ JSON encoding error for key '\(key)': \(error)")
            }
        }
        else {
            Debugger.printd("❌ Unable to encode value for key '\(key)'")
        }
    }
    
    public func decode(from aDecoder: NSCoder) {
        if let decoded = aDecoder.decodeObject(forKey: key) as? T {
            self.wrappedValue = decoded
        } else if let data = aDecoder.decodeObject(forKey: key) as? Data {
            do {
                let decoded = try JSONDecoder().decode(QDataAnyDecodable.self, from: data)
                self.wrappedValue = decoded.value as? T
            } catch {
                Debugger.printd("❌ JSON decoding error for key '\(key)': \(error)")
            }
        }
    }
    
    public func resetValue() {
        wrappedValue = defaultValue
    }
}
