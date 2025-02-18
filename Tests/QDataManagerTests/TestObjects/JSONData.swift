//
//  JSONData.swift
//  QDataManager
//
//  Created by Junkyu Jeon on 2/18/25.
//

import Foundation

public class UserData: Codable, Hashable {
    var id: UUID {
        return _id
    }
    private var _id = UUID()
    
    public var userID: String

    public init(userID: String) {
        self.userID = userID
    }
    
    public static func == (lhs: UserData, rhs: UserData) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
