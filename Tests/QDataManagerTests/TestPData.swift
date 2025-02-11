//
//  File.swift
//  QDataManager
//
//  Created by Junkyu Jeon on 2/11/25.
//

import Foundation

class TestPData: PDataObject {
    override class var supportsSecureCoding: Bool {
        return true
    }
    
    @objc var created: Date?
    @objc var updated: Date?
    @objc var mailbox_id: Int = -1
    @objc var content_id: Int = -1
    
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(mailbox_id)
        hasher.combine(content_id)
        hasher.combine(created)
        return hasher.finalize()
    }
}
