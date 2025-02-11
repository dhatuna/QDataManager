//
//  File.swift
//  QDataManager
//
//  Created by Junkyu Jeon on 2/11/25.
//

import Foundation

import QDataManager

class PDataObject: QDataObject {
    private static let _dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXX"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
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
                        if let date = PioDataObject._dateFormatter.date(from: dateString) {
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
