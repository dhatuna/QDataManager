//
//  File.swift
//  QDataManager
//
//  Created by Junkyu Jeon on 2/13/25.
//

import Foundation

class TestClass: TestDataObject {
    override class var supportsSecureCoding: Bool {
        return true
    }
    
    @objc var created: Date?
    @objc var identifier: Int = -1
    @objc var intValue: Int = -1
    @objc var strValue: String?
    @objc var subdata: TestSubClass?
    
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        hasher.combine(intValue)
        return hasher.finalize()
    }
}

class TestSubClass: TestDataObject {
    override class var supportsSecureCoding: Bool {
        return true
    }
    
    @objc var created: Date?
    @objc var identifier: Int = -1
    @objc var type: String?
    @objc var type2: String?
    @objc var moreData: [String:Any]?
    
    class func getSubClass(with content: QTestSubdataStruct) -> TestSubClass {
        return TestSubClass(with: content)
    }
}
