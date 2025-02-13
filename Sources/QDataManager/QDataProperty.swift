//
//  QDataProperty.swift
//  QDataManager
//
//  Created by Junkyu Jeon on 2/2/25.
//

import Foundation

@propertyWrapper
public final class QDataProperty<T>: QDataPropertyProtocol {
    public var wrappedValue: T?
    public let key: String
    public let defaultValue: T?
    public let elementDecoder: ((Any) -> Any?)?
    
    public init(_ key: String, defaultValue: T? = nil, elementDecoder: ((Any) -> Any?)? = nil) {
        self.key = key
        self.defaultValue = defaultValue
        self.elementDecoder = elementDecoder
    }
    
    public func encode(to aCoder: NSCoder) {
        guard let value = wrappedValue else { return }
        
        if let arrayValue = value as? [Any] {
            let nsArray = arrayValue as NSArray
            aCoder.encode(nsArray, forKey: key)
            return
        } else if let secureValue = value as? NSSecureCoding {
            aCoder.encode(secureValue, forKey: key)
            return
        } else if let encodableValue = value as? Encodable {
            do {
                let data = try JSONEncoder().encode(QDataAnyEncodable(encodableValue))
                aCoder.encode(data, forKey: key)
                return
            } catch {
                Debugger.printd("❌ JSON encoding error for key '\(key)': \(error)")
                return
            }
        }
        Debugger.printd("❌ Unable to encode value for key '\(key)'")
    }
    
    public func decode(from aDecoder: NSCoder) {
        if let data = aDecoder.decodeObject(of: QDataAllowedClasses.classes(), forKey: key) as? Data {
            if let type = T.self as? Decodable.Type {
                do {
                    self.wrappedValue = try JSONDecoder().decode(type, from: data) as? T
                    return
                } catch {
                    Debugger.printd("❌ Decoding error for key '\(key)': \(error)")
                }
            }
        } else if T.self == Int.self || T.self == Int?.self {
            self.wrappedValue = aDecoder.decodeObject(of: NSNumber.self, forKey: key)?.intValue as? T
        } else if T.self == String.self || T.self == String?.self {
            self.wrappedValue = aDecoder.decodeObject(of: NSString.self, forKey: key) as? T
        } else if T.self == Bool.self || T.self == Bool?.self {
            self.wrappedValue = aDecoder.decodeObject(of: NSNumber.self, forKey: key)?.boolValue as? T
        } else if T.self == Double.self || T.self == Double?.self {
            self.wrappedValue = aDecoder.decodeObject(of: NSNumber.self, forKey: key)?.doubleValue as? T
        } else if T.self == Float.self || T.self == Float?.self {
            self.wrappedValue = aDecoder.decodeObject(of: NSNumber.self, forKey: key)?.floatValue as? T
        } else if T.self == Date.self || T.self == Date?.self {
            if let dateString = aDecoder.decodeObject(of: NSString.self, forKey: key) as? String {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXX"
                formatter.locale = Locale(identifier: "en_US_POSIX")
                if let date = formatter.date(from: dateString) {
                    self.wrappedValue = date as? T
                }
            } else {
                self.wrappedValue = aDecoder.decodeObject(of: NSDate.self, forKey: key) as? T
            }
        } else if let decoded = aDecoder.decodeObject(forKey: key) as? T {
            self.wrappedValue = decoded
        } else {
            Debugger.printd("⚠️ Unable to decode value for key: \(key) - Type \(T.self) not supported")
        }
        
        
        if self.wrappedValue == nil {
            resetValue()
        }
    }
    
    public func resetValue() {
        wrappedValue = defaultValue
    }
}
