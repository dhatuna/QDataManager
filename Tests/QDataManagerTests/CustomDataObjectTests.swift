//
//  File.swift
//  QDataManager
//
//  Created by Junkyu Jeon on 2/13/25.
//


import XCTest
@testable import QDataManager
@testable import QUtils

@objc(DataManager)
private class DataManager: QDataManager {
    @QDataObjectArrayProperty("testArray", defaultValue: []) var testArray: [TestClass]!
    
    override class var supportsSecureCoding: Bool {
        return true
    }
}

final class QDataManagerTests: XCTestCase {
    override func setUpWithError() throws {
        return
    }

    override func tearDownWithError() throws {
        return
    }
    
    func testData() {
        QDataAllowedClasses.additionalClasses = [TestClass.self, TestSubClass.self, DataManager.self]
        
        let rawData: [[String:Any]] = [
            ["identifier": 1293443, "intValue": 411, "strValue": "test1", "created": "2024-12-30T03:30:09+09:00"],
            ["identifier": 1293522, "created": "2025-01-06T03:30:09+09:00", "intValue": 411, "strValue": "test2"],
            ["identifier": 1293594, "strValue": "test3", "created": "2025-01-13T03:30:08+09:00", "intValue": 411],
            ["created": "2025-01-20T03:30:08+09:00", "intValue": 411, "strValue": "test4", "identifier": 1293671],
            ["created": "2025-01-27T03:30:08+09:00", "strValue": "test5", "intValue": 544, "identifier": 1293831],
            ["intValue": 552, "created": "2025-02-01T01:00:09+09:00", "mailbox_id": 1294158, "strValue": "test6"],
            ["identifier": 1294279, "created": "2025-02-03T03:30:08+09:00", "intValue": 544, "strValue": "test7"],
            ["identifier": 1294425, "created": "2025-02-10T03:30:08+09:00", "strValue": "test8", "intValue": 544]]
        
        let array: [TestClass] = rawData.compactMap { item in
            guard item["identifier"] as? Int != nil else {
                return nil
            }
            return TestClass(with: item)
        }
        
        QDebugger.isEnabled = true
        
        var database = DataManager()
        database.clear()
        
        print("******* FIRST COMMIT *******")
        
        database.testArray = array
        database.commit()
        print(database.testArray.map({ item in
            return item.identifier
        }))
        XCTAssertEqual(database.testArray?.first?.identifier, 1293443)
        
        let box = database.testArray.first!
        box.subdata = TestSubClass(with: QTestSubdataStruct(created: Date(), identifier: 230, type: "TEST", type2: "TEST", moreData: [:]))
        database.testArray[0] = box
        database.commit()
        
        print("******* LOADING *******")
        
        database = DataManager.loadDatabase()
        
        print(database.testArray.map({ item in
            return item.identifier
        }))
        print(database.testArray?.first?.subdata?.identifier)
        
        XCTAssertEqual(database.testArray?.first?.identifier == nil, false)
    }
}
