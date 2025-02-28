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
    
    public class func printProgressBar(progress: Double, total: Double, length: Int = 30) {
        guard QDebugger.isEnabled else { return }
        
        let width = length
        let percent = Int((progress / total) * 100)
        let completed = Int((progress / total) * Double(width))
        
        let bar = String(repeating: "█", count: completed) + String(repeating: "-", count: width - completed)
        print("\r[\(bar)] \(percent)%", terminator: "")

        if percent == 100 {
            print("\n✅ Done!")
        }
    }
}
