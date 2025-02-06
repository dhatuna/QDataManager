
import XCTest
@testable import QDataManager

@objc(DataManager)
class DataManager: QDataManager {
    @QDataProperty("name", defaultValue: "jon doe") var name: String?
    @QDataProperty("address") var address: String?
    @QDataProperty("testClass") var testClass: TestClass?
    @QDataProperty("testArray") var testArr: [TestItem]?
    
    override class var supportsSecureCoding: Bool {
        return true
    }
}

class TestClass: QDataObject {
    @objc var str: String?
    @objc var int: Int = 0
    
    var interval: Int? {
        get {
            return int > 0 ? int : nil
        }
    }
    
    override class var supportsSecureCoding: Bool {
        return true
    }
}

class TestItem: QDataObject {
    @objc var title: String?
    
    override class var supportsSecureCoding: Bool {
        return true
    }
    
    init(title: String? = nil) {
        super.init()
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
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
        
        var testArr = [TestItem]()
        testArr.append(TestItem(title: "test1"))
        testArr.append(TestItem(title: "test2"))
        manager.testArr = testArr
        
        manager.commit()
        
        
        var loadedManager = DataManager.loadDatabase()
        XCTAssertEqual(loadedManager.name, name)
        XCTAssertEqual(loadedManager.address, address)
        XCTAssertEqual(loadedManager.testClass?.str, clsString)
        XCTAssertEqual(loadedManager.testClass?.int, clsInt)
        XCTAssertEqual(loadedManager.testArr?.count ?? 0, testArr.count)
        
        loadedManager.clear()
        loadedManager = DataManager.loadDatabase()
        XCTAssertEqual(loadedManager.name, "jon doe")
        XCTAssertEqual(loadedManager.address, nil)
        XCTAssertEqual(loadedManager.testClass?.str, nil)
        XCTAssertEqual(loadedManager.testClass?.int, nil)
    }
}
