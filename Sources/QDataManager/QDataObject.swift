//
//  File.swift
//  QDataManager
//
//  Created by Junkyu Jeon on 2/6/25.
//

import Foundation

open class QDataObject: NSObject, NSSecureCoding {
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
            } else {
                coder.encode(child.value, forKey: label)
            }
        }
    }
    
    required public init?(coder: NSCoder) {
        super.init()
        
//        let mirror = Mirror(reflecting: self)
//        for child in mirror.children {
//            guard let label = child.label else { continue }
//            
//            print("\(label), \(child.value)")
//            
//            if let property = child.value as? (any QDataPropertyProtocol) {
//                print("property : \(label) - \(property)")
//                property.decode(from: coder)
//            } else {
//                if coder.containsValue(forKey: label) {
//                    if let currentValue = self.value(forKey: label) {
//                        print("no property : \(label) - \(currentValue)")
//                        switch currentValue {
//                        case is Int:
//                            let intValue = coder.decodeInteger(forKey: label)
//                            self.setValue(intValue, forKey: label)
//                        case is Double:
//                            let doubleValue = coder.decodeDouble(forKey: label)
//                            self.setValue(doubleValue, forKey: label)
//                        case is Bool:
//                            let boolValue = coder.decodeBool(forKey: label)
//                            self.setValue(boolValue, forKey: label)
//                        case is Date:
//                            if let date = coder.decodeObject(of: NSDate.self, forKey: label) as? Date {
//                                self.setValue(date, forKey: label)
//                            } else {
//                                Debugger.printd("Warning: Could not decode Date for key \(label)")
//                            }
//                        default:
//                            if let decodedValue = coder.decodeObject(forKey: label) {
//                                self.setValue(decodedValue, forKey: label)
//                            } else {
//                                Debugger.printd("Warning: Could not decode value for key \(label)")
//                            }
//                        }
//                    } else {
//                        Debugger.printd("Warning: No current value for key \(label) to infer type")
//                    }
//                } else {
//                    Debugger.printd("Warning: No value in coder for key \(label)")
//                }
//            }
//        }
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
