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
    // Optionally, an initializer closure for arrays
    public let elementDecoder: ((Any) -> Any?)?
    
    public init(_ key: String, defaultValue: T? = nil, elementDecoder: ((Any) -> Any?)? = nil) {
        self.key = key
        self.defaultValue = defaultValue
        self.elementDecoder = elementDecoder
    }
    
    public func encode(to aCoder: NSCoder) {
        guard let value = wrappedValue else { return }
        // Array or dictionary branch…
        if let arrayValue = value as? [Any] {
            let nsArray = arrayValue as NSArray
            aCoder.encode(nsArray, forKey: key)
            return
        }
        // ... other branches (NSSecureCoding, JSON, etc.)
        else if let secureValue = value as? NSSecureCoding {
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
//    
//    public func decode(from aDecoder: NSCoder) {
//        let decodedObject = aDecoder.decodeObject(forKey: key)
//        
//        // If T is an array type, and elementDecoder is provided:
//        if let array = decodedObject as? NSArray, let elementDecoder = elementDecoder, T.self is [Any].Type {
//            let mappedArray = array.compactMap { elementDecoder($0) }
//            self.wrappedValue = mappedArray as? T
//            return
//        }
//        
//        if let decoded = decodedObject as? T {
//            self.wrappedValue = decoded
//            return
//        }
//        
//        if let data = decodedObject as? Data {
//            do {
//                let decoded = try JSONDecoder().decode(QDataAnyDecodable.self, from: data)
//                self.wrappedValue = decoded.value as? T
//            } catch {
//                Debugger.printd("❌ JSON decoding error for key '\(key)': \(error)")
//            }
//        }
//    }
    public func decode(from aDecoder: NSCoder) {
        if let data = aDecoder.decodeObject(of: NSData.self, forKey: key) as? Data {
            // ✅ T가 Decodable을 준수하는 경우에만 디코딩을 시도
            if let type = T.self as? Decodable.Type {
                do {
                    self.wrappedValue = try JSONDecoder().decode(type, from: data) as? T
                    return
                } catch {
                    Debugger.printd("❌ Decoding error for key '\(key)': \(error)")
                }
            }
        }

        // ✅ Int 타입 처리
        if T.self == Int.self || T.self == Int?.self {
            self.wrappedValue = (aDecoder.decodeInteger(forKey: key) as Int) as? T
        }
        // ✅ String 타입 처리
        else if T.self == String.self || T.self == String?.self {
            self.wrappedValue = aDecoder.decodeObject(of: NSString.self, forKey: key) as? T
        }
        // ✅ Bool 타입 처리
        else if T.self == Bool.self || T.self == Bool?.self {
            self.wrappedValue = (aDecoder.decodeBool(forKey: key) as Bool) as? T
        }
        // ✅ Double 타입 처리
        else if T.self == Double.self || T.self == Double?.self {
            self.wrappedValue = (aDecoder.decodeDouble(forKey: key) as Double) as? T
        }
        // ✅ Date 타입 처리 (String으로 저장된 경우 대비)
        else if T.self == Date.self || T.self == Date?.self {
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
        }
        // ✅ 기타 지원되지 않는 타입 처리
        else {
            Debugger.printd("⚠️ Unable to decode value for key: \(key) - Type \(T.self) not supported")
        }
    }
    
    public func resetValue() {
        wrappedValue = defaultValue
    }
}
