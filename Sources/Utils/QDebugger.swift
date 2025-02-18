//
//  QDebugger.swift
//  QDataManager
//
//  Created by Junkyu Jeon on 2/18/25.
//

import Foundation

private final class IsEnabledHolder: @unchecked Sendable {
    var value: Bool = false
}

public final class QDebugger: @unchecked Sendable {
    private static let queue = DispatchQueue(label: "com.cocoslab.qdatamanager.QDebuggerQueue")
    private static let _holder = IsEnabledHolder()
    
    public static var isEnabled: Bool {
        get { return queue.sync { _holder.value } }
        set { queue.sync { _holder.value = newValue } }
    }
    
    public class func printd(_ string: String) {
        guard QDebugger.isEnabled else { return }
        print(string)
    }
}
