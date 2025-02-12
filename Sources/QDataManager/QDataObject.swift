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
            } else {
                let decodedValue = coder.decodeObject(forKey: label)
                if let decodedValue = decodedValue {
                    self.setValue(decodedValue, forKey: label)
                } else {
                    if let currentValue = self.value(forKey: label) {
                        switch currentValue {
                        case is Int:
                            let intValue = coder.decodeInteger(forKey: label)
                            self.setValue(intValue, forKey: label)
                        case is Double:
                            let doubleValue = coder.decodeDouble(forKey: label)
                            self.setValue(doubleValue, forKey: label)
                        case is Bool:
                            let boolValue = coder.decodeBool(forKey: label)
                            self.setValue(boolValue, forKey: label)
                        case is Date:
                            break
                        default:
                            Debugger.printd("Warning: Could not decode value for key \(label)")
                        }
                    } else {
                        Debugger.printd("Warning: No current value for key \(label) to infer type")
                    }
                }
            }
        }
    }
    
    override public init() {
        super.init()
    }
}
