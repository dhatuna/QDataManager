//
//  File.swift
//  QDataManager
//
//  Created by Junkyu Jeon on 2/13/25.
//

import Foundation

import QDataManager

class DataObject: QDataObject {
    convenience init(with rawDict: [String: Any]) {
        self.init()
        
        let mirror = Mirror(reflecting: self)
        
        for child in mirror.children {
            guard let propertyName = child.label else { continue }
            
            if let value = rawDict[propertyName] {
                let propertyType = type(of: child.value)
                
                switch propertyType {
                case is String.Type, is Optional<String>.Type:
                    self.setValue(value as? String, forKey: propertyName)
                case is Int.Type, is Optional<Int>.Type:
                    self.setValue(value as? Int, forKey: propertyName)
                case is Double.Type, is Optional<Double>.Type:
                    self.setValue(value as? Double, forKey: propertyName)
                case is Bool.Type, is Optional<Bool>.Type:
                    self.setValue(value as? Bool, forKey: propertyName)
                case is Date.Type, is Optional<Date>.Type:
                    if let dateString = value as? String {
                        if let date = DataObject._dateFormatter.date(from: dateString) {
                            self.setValue(date, forKey: propertyName)
                        }
                    }
                default:
                    break
                }
            }
        }
    }
}

class TestDataObject: QDataObject {
    convenience init(with rawDict: [String: Any]) {
        self.init()
        self._setValues(from: rawDict)
    }
    
    convenience init<T: Codable>(with codable: T) {
        self.init()
        if let dict = codable.toDictionary() {
            self._setValues(from: dict)
        }
    }
    
    private func _setValues(from dict: [String: Any]) {
        let mirror = Mirror(reflecting: self)
        
        for child in mirror.children {
            guard let propertyName = child.label else { continue }
            if let value = dict[propertyName] {
                let propertyType = type(of: child.value)
                
                switch propertyType {
                case is String.Type, is Optional<String>.Type:
                    self.setValue(value as? String, forKey: propertyName)
                case is Int.Type, is Optional<Int>.Type:
                    self.setValue(value as? Int, forKey: propertyName)
                case is Double.Type, is Optional<Double>.Type:
                    self.setValue(value as? Double, forKey: propertyName)
                case is Bool.Type, is Optional<Bool>.Type:
                    self.setValue(value as? Bool, forKey: propertyName)
                case is Date.Type, is Optional<Date>.Type:
                    if let dateString = value as? String,
                       let date = TestDataObject._dateFormatter.date(from: dateString) {
                        self.setValue(date, forKey: propertyName)
                    }
                case is [String: AnyCodable].Type, is Optional<[String: AnyCodable]>.Type:
                    if let anyCodableDict = value as? [String: AnyCodable] {
                        self.setValue(anyCodableDict.toAnyDictionary(), forKey: propertyName)
                    }
                default:
                    break
                }
            }
        }
    }
}
