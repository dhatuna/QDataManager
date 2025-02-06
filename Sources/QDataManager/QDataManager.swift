// The Swift Programming Language
// https://docs.swift.org/swift-book
//
//  QDataManager.swift
//  QKit
//
//  Created by Jun-kyu Jeon on 02/03/2017.
//  Copyright © 2018 Cocoslab. All rights reserved.
//

import Foundation
import SQLite3

let kFileName = "settingsV1"
let kFileExtension = "dat"
let kFile = kFileName + "." + kFileExtension

let kDirectory = FileManager.SearchPathDirectory.documentDirectory
let kDomainMask = FileManager.SearchPathDomainMask.userDomainMask

class Debugger {
    class var isEnabled: Bool {
        return true
    }
    
    class func printd(_ string: String) {
        guard Debugger.isEnabled else { return }
        print(string)
    }
}

open class QDataManager : NSObject, NSSecureCoding {
    @objc open class var supportsSecureCoding: Bool {
        fatalError("\(Self.self) must override `supportsSecureCoding` with `true`")
    }
    
    var version = Int32(1)
    
    var allProperties: [String:Any] {
        get {
            let mirror = Mirror(reflecting: self)
            var props = [String:Any]()
            
            for (key, value) in mirror.children {
                guard let key = key else { continue }
                props[key] = value
            }
            
            return props
        }
    }
    
    @QDataProperty("uuid") var uuid: String?
    
    required override public init() {
        super.init()
        assert(type(of: self).supportsSecureCoding, "\(type(of: self)) must implement `supportsSecureCoding`")
    }

    required public init(_ manager: QDataManager) {
        super.init()
        self.version = manager.version
        
        self.uuid = manager.uuid
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init()
        
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            guard let _ = child.label else { continue }
            if let property = child.value as? any QDataPropertyProtocol {
                Debugger.printd("📌 Decoded value: \(child.label!) = \(property)")
                property.decode(from: aDecoder)
            }
        }
    }
    
    public func commit() {
        guard let directory = NSSearchPathForDirectoriesInDomains(kDirectory, kDomainMask, true).first else {
            return
        }

        let filePath = (directory as NSString).appendingPathComponent("\(type(of: self)).\(kFileExtension)".lowercased())

        do {
            let fileUrl = URL(fileURLWithPath: filePath)
            let archivedData = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: true)
            try archivedData.write(to: fileUrl)
            Debugger.printd("✅ Saving data succeeded: \(filePath)")
        } catch {
            Debugger.printd("❌ Saving data failed: \(error)")
        }
    }
    
    public func clear() {
        let mirror = Mirror(reflecting: self)
        
        for child in mirror.children {
            guard let key = child.label else { continue }
            
            if let propertyWrapper = child.value as? (any QDataPropertyProtocol) {
                propertyWrapper.resetValue()
            } else {
                self.setValue(nil, forKey: key)
            }
        }
        commit()
    }
}

extension QDataManager {
    class func getAllClasses() -> [AnyClass] {
        var clsArray: [AnyClass] = [self, NSString.self, NSNumber.self, NSData.self, NSArray.self, NSDictionary.self, QDataObject.self]
        
        let numberOfClasses = objc_getClassList(nil, 0)
        
        if numberOfClasses > 0 {
            let allClasses = UnsafeMutablePointer<AnyClass>.allocate(capacity: Int(numberOfClasses))
            defer { allClasses.deallocate() }
            
            let actualCount = objc_getClassList(AutoreleasingUnsafeMutablePointer(allClasses), numberOfClasses)
            
            for i in 0..<Int(actualCount) {
                let cls: AnyClass = allClasses[i]
                guard class_getSuperclass(cls) == self || class_getSuperclass(cls) == QDataObject.self else { continue }
                clsArray.append(cls)
            }
        }
        
        return clsArray
    }
    
    public class func loadDatabase() -> Self {
        guard let directory = NSSearchPathForDirectoriesInDomains(kDirectory, kDomainMask, true).first else {
            Debugger.printd("❌ Load database failed: Unable to find database file.")
            return Self()
        }
        
        
        let filename = ("\(type(of: self))".components(separatedBy: ".").first ?? "").lowercased()
        let filePath = (directory as NSString).appendingPathComponent("\(filename).\(kFileExtension)".lowercased())

        do {
            let fileUrl = URL(fileURLWithPath: filePath)
            let fileData = try Data(contentsOf: fileUrl)
            
            let classes = getAllClasses()
            
            if let dataManager = try NSKeyedUnarchiver.unarchivedObject(ofClasses: classes, from: fileData) as? Self {
                Debugger.printd("✅ Loading data succeeded: \(filePath)")

                if dataManager.version != Self().version {
                    Debugger.printd("⚠️ Database version has been changed: Database initialised.")
                    let newDataManager = Self()
                    newDataManager.commit()
                    _ = newDataManager.sqlite()
                    return newDataManager
                }

                _ = dataManager.sqlite()
                return dataManager
            } else {
                Debugger.printd("⚠️ Unarchiving data failed: returning default value.")
            }
        } catch {
            Debugger.printd("❌ Loading data failed: \(error)")
        }

        let newDataManager = Self()
        _ = newDataManager.sqlite()
        return newDataManager
    }
    
    func sqlite() -> Bool {
        do {
            var database: OpaquePointer?
            let manager = FileManager.default
            let documentUrl = try manager.url(for: kDirectory, in: kDomainMask, appropriateFor: nil, create: false).appendingPathComponent("\(type(of: self)).sqlite".lowercased())

            if sqlite3_open(documentUrl.path, &database) == SQLITE_OK {
                var statement: OpaquePointer?
                var userVersion = Int32(0)

                let query = "PRAGMA user_version;"
                if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK {
                    if sqlite3_step(statement) == SQLITE_ROW {
                        userVersion = sqlite3_column_int(statement, 0)
                    }
                }
                sqlite3_finalize(statement)

                if version > userVersion {
                    let createQuery = "CREATE TABLE IF NOT EXISTS statuses (id INTEGER PRIMARY KEY, hit_date REAL);"
                    sqlite3_exec(database, createQuery, nil, nil, nil)
                    let versionQuery = "PRAGMA user_version=\(version);"
                    sqlite3_exec(database, versionQuery, nil, nil, nil)
                }
            } else {
                Debugger.printd("❌ Loading SQLite database failed")
                return false
            }
        } catch {
            Debugger.printd("❌ Initialising SQLite database failed: \(error)")
            return false
        }
        return true
    }
}

extension QDataManager: NSCopying, NSCoding {
    public func copy(with zone: NSZone? = nil) -> Any {
        return type(of: self).init(self)
    }
    
    public func encode(with aCoder: NSCoder) {
        let mirror = Mirror(reflecting: self)

        for child in mirror.children {
            guard let _ = child.label else { continue }

            if let property = child.value as? any QDataPropertyProtocol {
                Debugger.printd("📌 Encoded value: \(child.label!) = \(property)")
                property.encode(to: aCoder)
            }
        }
    }
}
