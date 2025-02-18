//
//  File.swift
//  QDataManager
//
//  Created by Junkyu Jeon on 2/18/25.
//

import XCTest
@testable import QJSONDataManager
@testable import QUtils

@objc(UserIdManager)
class UserIdManager: QJSONDataManager<UserData> {}

final class JSONDataManagerTests: XCTestCase {
    override func setUpWithError() throws {
        return
    }

    override func tearDownWithError() throws {
        return
    }
    
    func testChild() throws {
        var manager = UserIdManager.loadDatabase()
        manager.items.append(UserData(userID: "1"))
        manager.items.append(UserData(userID: "2"))
        manager.items.append(UserData(userID: "3"))
        manager.items.append(UserData(userID: "4"))
        manager.commit()
        
        manager = UserIdManager.loadDatabase()
        XCTAssertEqual(manager.items[0].userID, "1")
        XCTAssertEqual(manager.items[1].userID, "2")
        XCTAssertEqual(manager.items[2].userID, "3")
        XCTAssertEqual(manager.items[3].userID, "4")
    }
}
