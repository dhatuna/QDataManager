
import XCTest
@testable import QDataManager

@objc(DataManager)
class DataManager: QDataManager {
    @QDataProperty("name", defaultValue: "jon doe") var name: String?
    @QDataProperty("address") var address: String?
    @QDataProperty("testClass") var testClass: TestClass?
    @QDataProperty("anObject") var anObject: PDataObject?
    @QDataProperty("objects", defaultValue: []) var objects: [PDataObject]!
    
    override class var supportsSecureCoding: Bool {
        return true
    }
}

class TestClass: QDataObject {
    @objc var str: String?
    @objc var int: Int = 0
    @objc var item: TestItem?
    
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
        let clsItem = TestItem(title: "title")
        
        let manager = DataManager.loadDatabase()
        manager.name = name
        manager.address = address
        
        let testCls = TestClass()
        testCls.str = clsString
        testCls.int = clsInt
        testCls.item = clsItem
        manager.testClass = testCls
        
        var rawValue = [String:Any]()
        rawValue["content_id"] = 544
        rawValue["mailbox_id"] = 1294425
        rawValue["created"] = "2025-02-10T03:30:08+09:00"
        rawValue["updated"] = "2025-02-10T03:30:08+09:00"
        let mailbox = MailboxList(with: rawValue)
        
        manager.oneMailbox = mailbox
        manager.mailbox = [mailbox]
        
        manager.commit()
        
        
        var loadedManager = DataManager.loadDatabase()
        XCTAssertEqual(loadedManager.name, name)
        XCTAssertEqual(loadedManager.address, address)
        XCTAssertEqual(loadedManager.testClass?.str, clsString)
        XCTAssertEqual(loadedManager.testClass?.int, clsInt)
        XCTAssertEqual(loadedManager.testClass?.item?.title, clsItem.title)
        XCTAssertEqual(loadedManager.oneMailbox?.hash, mailbox.hash)
        XCTAssertEqual(loadedManager.mailbox?.first?.hash, mailbox.hash)
        
        print(loadedManager.testClass?.item?.title ?? "")
        
        loadedManager.clear()
        loadedManager = DataManager.loadDatabase()
        XCTAssertEqual(loadedManager.name, "jon doe")
        XCTAssertEqual(loadedManager.address, nil)
        XCTAssertEqual(loadedManager.testClass?.str, nil)
        XCTAssertEqual(loadedManager.oneMailbox?.hash, nil)
        XCTAssertEqual(loadedManager.mailbox?.first?.hash, nil)
    }
}
