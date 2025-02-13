//
//  File.swift
//  QDataManager
//
//  Created by Junkyu Jeon on 2/2/25.
//

import Foundation

public protocol QDataPropertyProtocol {
    func encode(to aCoder: NSCoder)
    func decode(from aDecoder: NSCoder)
    func resetValue()
}
