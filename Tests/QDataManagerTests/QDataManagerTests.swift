
import XCTest
@testable import QDataManager

@objc(DataManager)
class DataManager: QDataManager {
    @QDataProperty("name", defaultValue: "jon doe") var name: String?
    @QDataProperty("address") var address: String?
    @QDataProperty("testClass") var testClass: TestClass?
    
    override class var supportsSecureCoding: Bool {
        return true
    }
}

class TestClass: QDataObject {
    @objc var str: String?
    @objc var int: Int = 0
    
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
        
        let clsString = "this is a test class"
        let clsInt = 42
        
        let manager = DataManager.loadDatabase()
        manager.name = name
        manager.address = address
        
        let testCls = TestClass()
        testCls.str = clsString
        testCls.int = clsInt
        manager.testClass = testCls
        
        manager.commit()
        
        
        var loadedManager = DataManager.loadDatabase()
        XCTAssertEqual(loadedManager.name, name)
        XCTAssertEqual(loadedManager.address, address)
        XCTAssertEqual(loadedManager.testClass?.str, clsString)
        XCTAssertEqual(loadedManager.testClass?.int, clsInt)
        
        loadedManager.clear()
        loadedManager = DataManager.loadDatabase()
        XCTAssertEqual(loadedManager.name, "jon doe")
        XCTAssertEqual(loadedManager.address, nil)
        XCTAssertEqual(loadedManager.testClass?.str, nil)
        XCTAssertEqual(loadedManager.testClass?.int, nil)
    }
}
