
import XCTest
@testable import QDataManager

@objc(DataManager)
class DataManager: QDataManager {
    @QDataProperty("name") var name: String?
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
        
        let manager = DataManager.loadDatabase()
        manager.name = name
        manager.address = "test addr"
        manager.commit()
        
        let loadedManager = DataManager.loadDatabase()
        XCTAssertEqual(loadedManager.name, name)
    }
}
