
import XCTest
@testable import QDataManager

@objc(ADataManager)
private class ADataManager: QDataManager {
    @QDataProperty("name", defaultValue: "jon doe") var name: String?
    @QDataProperty("address") var address: String?
    @QDataProperty("testClass") var testClass: TestClass?
    @QDataProperty("anObject") var anObject: ADataObject?
    @QDataProperty("objects", defaultValue: []) var objects: [ADataObject]!
    
    override class var supportsSecureCoding: Bool {
        return true
    }
}

private class ADataObject: DataObject {
    @QDataProperty("title") var title: String?
}
    
final class DataManagerTests: XCTestCase {
    override func setUpWithError() throws {
        return
    }

    override func tearDownWithError() throws {
        return
    }
    
    func testChild() throws {
        Debugger.isEnabled = true
        QDataAllowedClasses.additionalClasses = [ADataObject.self, TestClass.self, TestSubClass.self, ADataManager.self]
        
        let name = "test name"
        let address = "test addr"
        
        let clsString = "this is a test class"
        let clsInt = 42
        let clsItem = TestSubClass()
        clsItem.identifier = 84
        
        let manager = ADataManager.loadDatabase()
        manager.name = name
        manager.address = address
        
        let testCls = TestClass()
        testCls.strValue = clsString
        testCls.identifier = clsInt
        testCls.subdata = clsItem
        manager.testClass = testCls
        
        manager.commit()
        
        
        var loadedManager = ADataManager.loadDatabase()
        XCTAssertEqual(loadedManager.name, name)
        XCTAssertEqual(loadedManager.address, address)
        XCTAssertEqual(loadedManager.testClass?.strValue, clsString)
        XCTAssertEqual(loadedManager.testClass?.identifier, clsInt)
        XCTAssertEqual(loadedManager.testClass?.subdata?.identifier, clsItem.identifier)
        
        print(loadedManager.testClass?.subdata?.type ?? "")
        
        loadedManager.clear()
        loadedManager = ADataManager.loadDatabase()
        XCTAssertEqual(loadedManager.name, "jon doe")
        XCTAssertEqual(loadedManager.address, nil)
        XCTAssertEqual(loadedManager.testClass?.strValue, nil)
    }
}
