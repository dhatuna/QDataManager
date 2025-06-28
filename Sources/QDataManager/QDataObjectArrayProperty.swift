//
//  File.swift
//  QDataManager
//
//  Created by Junkyu Jeon on 2/13/25.
//

import Foundation

import QUtils

@propertyWrapper
public final class QDataObjectArrayProperty<Element: QDataObject>: QDataPropertyProtocol {
    public var wrappedValue: [Element]?
    public let key: String
    public let defaultValue: [Element]?
    
    public init(_ key: String, defaultValue: [Element]? = nil) {
        self.key = key
        self.defaultValue = defaultValue
        if defaultValue != nil {
            self.wrappedValue = defaultValue
        }
    }
    
    public func encode(to aCoder: NSCoder) {
        guard let value = wrappedValue else { return }
        aCoder.encode(value as NSArray, forKey: key)
        QDebugger.printd("📌 Encoded '\(key)': \(value.count) items")
    }
    
    public func decode(from aDecoder: NSCoder) {
        let allowedClasses = QDataAllowedClasses.classes()
        if let decodedArray = aDecoder.decodeObject(of: allowedClasses, forKey: key) as? [Element] {
            self.wrappedValue = decodedArray
            QDebugger.printd("📌 Decoded '\(key)': \(decodedArray.count) items")
        } else {
            QDebugger.printd("⚠️ Failed to decode '\(key)', using default value.")
            resetValue()
        }
    }
    
    public func resetValue() {
        wrappedValue = defaultValue
    }
}
