//
//  File.swift
//  QDataManager
//
//  Created by Junkyu Jeon on 2/13/25.
//

import Foundation

@propertyWrapper
public final class QDataObjectArrayProperty<Element: QDataObject>: QDataPropertyProtocol {
    public var wrappedValue: [Element]?
    public let key: String
    public let defaultValue: [Element]?
    
    public init(_ key: String, defaultValue: [Element]? = nil) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public func encode(to aCoder: NSCoder) {
        guard let value = wrappedValue else { return }
        
        let nsArray = NSMutableArray()
        for element in value {
            nsArray.add(element)
        }
        aCoder.encode(nsArray, forKey: key)
        
        Debugger.printd("📌 Encoded '\(key)': \(nsArray)")
    }
    
    public func decode(from aDecoder: NSCoder) {
        if let nsArray = aDecoder.decodeObject(of: QDataAllowedClasses.classes(), forKey: key) as? NSArray {
            var decodedArray: [Element] = []
            
            for case let element as Element in nsArray {
                decodedArray.append(element)
            }
            
            self.wrappedValue = decodedArray
        }

        Debugger.printd("📌 Decoded '\(key)': \(wrappedValue ?? [])")
    }
    
    public func resetValue() {
        wrappedValue = defaultValue
    }
}
