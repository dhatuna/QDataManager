//
//  QThreadSafeStore.swift
//  QDataManager
//
//  Created by Junkyu Jeon on 6/28/25.
//

import Foundation

public final class QThreadSafeStore<T: Sendable>: @unchecked Sendable {
    private let _lock = NSLock()
    private var _value: T
    
    init(initValue: T) {
        self._value = initValue
    }
    
    var value: T {
        get {
            _lock.lock()
            defer { _lock.unlock() }
            return _value
        }
    }
    
    func setValue(_ newValue: T) {
        _lock.lock()
        defer { _lock.unlock() }
        self._value = newValue
    }
}
