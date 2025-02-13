//
//  File.swift
//  QDataManager
//
//  Created by Junkyu Jeon on 2/6/25.
//

import Foundation

open class QDataObject: NSObject, NSSecureCoding {
    public static let _dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXX"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    @objc open class var supportsSecureCoding: Bool {
        fatalError("\(Self.self) must override `supportsSecureCoding` with `true`")
    }
    
    open func encode(with coder: NSCoder) {
        let mirror = Mirror(reflecting: self)
        
        for child in mirror.children {
            guard let label = child.label else { continue }
            
            if let property = child.value as? (any QDataPropertyProtocol) {
                property.encode(to: coder)
            } else if let dataObject = child.value as? QDataObject {
                coder.encode(dataObject, forKey: label)
            } else if let intValue = child.value as? Int {
                coder.encode(NSNumber(value: intValue), forKey: label)
            } else if let doubleValue = child.value as? Double {
                coder.encode(NSNumber(value: doubleValue), forKey: label)
            } else if let floatValue = child.value as? Float {
                coder.encode(NSNumber(value: floatValue), forKey: label)
            } else if let boolValue = child.value as? Bool {
                coder.encode(NSNumber(value: boolValue), forKey: label)
            } else if let dateValue = child.value as? Date {
                coder.encode(dateValue as NSDate, forKey: label)
            } else if let strValue = child.value as? String {
                coder.encode(strValue as NSString, forKey: label)
            } else {
                coder.encode(child.value, forKey: label)
            }
        }
    }
    
    required public init?(coder: NSCoder) {
        super.init()
        
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            guard let label = child.label else { continue }
            
            if let property = child.value as? (any QDataPropertyProtocol) {
                property.decode(from: coder)
                continue
            }
            
            var object = coder.decodeObject(of: QDataAllowedClasses.classes(), forKey: label)
            if object is NSNull { object = nil }
            
            let defaultValue = self.value(forKey: label)
            
            switch child.value {
            case is Int:
                self.setValue((object as? NSNumber)?.intValue ?? defaultValue, forKey: label)
            case is Double:
                self.setValue((object as? NSNumber)?.doubleValue ?? defaultValue, forKey: label)
            case is Float:
                self.setValue((object as? NSNumber)?.floatValue ?? defaultValue, forKey: label)
            case is Bool:
                self.setValue((object as? NSNumber)?.boolValue ?? defaultValue, forKey: label)
            case is Date:
                self.setValue(object as? Date ?? defaultValue, forKey: label)
            default:
                self.setValue(object ?? defaultValue, forKey: label)
                break
            }
        }
    }
    
    override public init() {
        super.init()
    }
    
    private func _getPropertyType<T>(of object: T, propertyName: String) -> Any.Type? {
        let mirror = Mirror(reflecting: object)
        
        for child in mirror.children {
            if let label = child.label, label == propertyName {
                return type(of: child.value)
            }
        }
        return nil
    }
}
