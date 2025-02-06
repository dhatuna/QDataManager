//
//  File.swift
//  QDataManager
//
//  Created by Junkyu Jeon on 2/6/25.
//

import Foundation

public class QDataObject: NSObject, NSSecureCoding {
    @objc public class var supportsSecureCoding: Bool {
        fatalError("\(Self.self) must override `supportsSecureCoding` with `true`")
    }
    
    public func encode(with coder: NSCoder) {
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
                self.setValue(decodedValue, forKey: label)
            }
        }
    }
    
    override public init() {
        super.init()
    }
}
