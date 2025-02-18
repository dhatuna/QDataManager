//
//  File.swift
//  QDataManager
//
//  Created by Junkyu Jeon on 2/18/25.
//

import Foundation
import Combine

import QUtils

public class QJSONDataManager<T: Codable>: ObservableObject {
    @Published var items: [T] = []
    
    private static var _fileName: String {
        return "\(String(describing: Self.self).lowercased()).json.enc"
    }

    required public init() {}
    
    public func commit() {
        let fileURL = Self._getFilePath()
        do {
            let jsonData = try JSONEncoder().encode(items)
            let encryptedData = try QAESCryptoHelper.encrypt(jsonData)
            try encryptedData.write(to: fileURL)
            QDebugger.printd("✅ encrypted JSON data successfully saved: \(fileURL)")
        } catch {
            QDebugger.printd("❌ encrypted JSON data failed to save: \(error)")
        }
    }

    public static func loadDatabase() -> Self {
        let manager = Self()
        let fileURL = _getFilePath()

        do {
            let encryptedData = try Data(contentsOf: fileURL)
            let jsonData = try QAESCryptoHelper.decrypt(encryptedData)
            manager.items = try JSONDecoder().decode([T].self, from: jsonData)
            QDebugger.printd("✅ encrypted JSON data successfully loaded: \(fileURL)")
        } catch {
            QDebugger.printd("⚠️ encrypted JSON data failed to load: \(error)")
        }

        return manager
    }

    private static func _getFilePath() -> URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return directory.appendingPathComponent(_fileName)
    }
}
