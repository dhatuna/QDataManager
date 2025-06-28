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
import CoreFoundation

import QUtils

let kFileName = "settingsV1"
let kFileExtension = "dat"
let kFile = kFileName + "." + kFileExtension

let kDirectory = FileManager.SearchPathDirectory.documentDirectory
let kDomainMask = FileManager.SearchPathDomainMask.userDomainMask

private final class AllowedClasses: @unchecked Sendable {
    var value: [AnyClass] = []
}

public final class QDataAllowedClasses: @unchecked Sendable {
    private static let classStore = QThreadSafeStore<[AnyClass]>(initValue: [])
    
    public static var additionalClasses: [AnyClass] {
        get {
            return classStore.value
        }
        set {
            classStore.setValue(newValue)
        }
    }
    
    public class func classes() -> [AnyClass] {
        var allowedClasses = [AnyClass]()
        var checkedClasses = Set<ObjectIdentifier>()
        
        let baseClasses: [AnyClass] = [
            NSArray.self,
            NSMutableArray.self,
            NSDictionary.self,
            NSString.self,
            NSDate.self,
            NSNumber.self,
            NSNull.self,
            NSData.self,
            QDataObject.self
        ]
        
        for cls in baseClasses {
            let id = ObjectIdentifier(cls)
            
            guard !checkedClasses.contains(id) else { continue }
            
            allowedClasses.append(cls)
            checkedClasses.insert(id)
        }
        
        for item in self.additionalClasses {
            var userClass: AnyClass? = item
            
            while let cls = userClass {
                if cls == NSObject.self || class_getSuperclass(cls) == nil {
                    break
                }
                
                let id = ObjectIdentifier(cls)
                if !checkedClasses.contains(id) {
                    allowedClasses.append(cls)
                    checkedClasses.insert(id)
                }
                
                userClass = class_getSuperclass(cls)
            }
        }
        
        return allowedClasses
    }
}



open class QDataManager : NSObject, NSSecureCoding {
    @objc open class var supportsSecureCoding: Bool {
        fatalError("\(Self.self) must override `supportsSecureCoding` with `true`")
    }
    
    var version = Int32(1)
    @QDataProperty("uuid") var uuid: String?
    
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
    
    required override public init() {
        super.init()
        
        initialize()
    }

    required public init(_ manager: QDataManager) {
        super.init()
        
        initialize()
        
        self.version = manager.version
        
        self.uuid = manager.uuid
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init()
        
        initialize()
        
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            guard let _ = child.label else { continue }
            if let property = child.value as? any QDataPropertyProtocol {
                QDebugger.printd("📌 Decoded value: \(child.label!) = \(property)")
                property.decode(from: aDecoder)
            }
        }
    }
    
    open func initialize() {
        assert(type(of: self).supportsSecureCoding, "\(type(of: self)) must implement `supportsSecureCoding`")
    }
    
    public func commit() {
        let filePath = Self.databasePath(for: type(of: self))
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: true)
            try data.write(to: URL(fileURLWithPath: filePath), options: .atomic)
            QDebugger.printd("✅ Save Succeeded: \(filePath)")
        } catch {
            QDebugger.printd("❌ Save Failed: \(error)")
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
        return QDataAllowedClasses.classes()
    }
    
    private static func databasePath(for cls: AnyClass) -> String {
        let directoryURL: URL
        
        #if DEBUG
        directoryURL = FileManager.default.temporaryDirectory
        #else
        directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        #endif
        
        let filename = String(describing: cls).components(separatedBy: ".").last!.lowercased()
        let fileURL = directoryURL.appendingPathComponent("\(filename).\(kFileExtension)")
        return fileURL.path
    }
    
    public class func loadDatabase() -> Self {
        let filePath = databasePath(for: self)

        guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
            let newInstance = Self()
            newInstance.commit()
            return newInstance
        }
        
        do {
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
            unarchiver.requiresSecureCoding = true
            
            let dataManager = try unarchiver.decodeTopLevelObject(of: self, forKey: NSKeyedArchiveRootObjectKey)
            try unarchiver.finishDecoding()
            
            if let manager = dataManager {
                QDebugger.printd("✅ Loading data succeeded: \(filePath)")
                if manager.version != Self().version {
                    QDebugger.printd("⚠️ Database version mismatch. Re-initializing.")
                    let newManager = Self()
                    newManager.commit()
                    return newManager
                }
                _ = manager.sqlite()
                return manager
            } else {
                QDebugger.printd("⚠️ Unarchiving failed. Creating a new one.")
            }
        } catch {
            QDebugger.printd("❌ Loading data failed: \(error)")
        }

        let newDataManager = Self()
        newDataManager.commit()
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
                QDebugger.printd("❌ Loading SQLite database failed")
                return false
            }
        } catch {
            QDebugger.printd("❌ Initialising SQLite database failed: \(error)")
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
                QDebugger.printd("📌 Encoded value: \(child.label!) = \(property)")
                property.encode(to: aCoder)
            }
        }
    }
}
