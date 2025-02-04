
import XCTest
@testable import QDataManager

@objc(DataManager)
class DataManager: QDataManager {
    @QDataProperty("name", defaultValue: "jon doe") var name: String?
    @QDataProperty("address") var address: String?
    
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
    
    func testChild() throws {
        let name = "test name"
        let address = "test addr"
        
        let manager = DataManager.loadDatabase()
        manager.name = name
        manager.address = address
        manager.commit()
        
        var loadedManager = DataManager.loadDatabase()
        XCTAssertEqual(loadedManager.name, name)
        XCTAssertEqual(loadedManager.address, address)
        
        loadedManager.clear()
        loadedManager = DataManager.loadDatabase()
        XCTAssertEqual(loadedManager.name, "jon doe")
        XCTAssertEqual(loadedManager.address, nil)
    }
}
