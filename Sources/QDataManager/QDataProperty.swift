//
//  QDataProperty.swift
//  QDataManager
//
//  Created by Junkyu Jeon on 2/2/25.
//

import Foundation

@propertyWrapper
public class QDataProperty<T: Codable>: QDataEncodableProperty, QDataDecodableProperty, QDataPropertyProtocol {
    private enum CodingKeys: String, CodingKey {
        case wrappedValue
        case key
        case defaultValue
    }

    public var wrappedValue: T?
    public let key: String
    public let defaultValue: T?
    
    public init(_ key: String, defaultValue: T? = nil) {
        self.key = key
        self.defaultValue = defaultValue
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // ✅ key와 defaultValue도 함께 복원
        self.key = try container.decode(String.self, forKey: .key)
        self.defaultValue = try? container.decode(T.self, forKey: .defaultValue)
        self.wrappedValue = try? container.decode(T.self, forKey: .wrappedValue)
    }

    public func encode(to aCoder: NSCoder) {
        guard let wrappedValue = wrappedValue else { return }
        
        do {
            let encodedData = try JSONEncoder().encode(wrappedValue)
            aCoder.encode(encodedData, forKey: key)
        } catch {
            Debugger.printd("❌ Encoding error for key '\(key)': \(error)")
        }
    }
    
    public func decode(from aDecoder: NSCoder) {
        if let data = aDecoder.decodeObject(of: NSData.self, forKey: key) as? Data {
            do {
                self.wrappedValue = try JSONDecoder().decode(T.self, from: data)
            } catch {
                Debugger.printd("❌ Decoding error for key '\(key)': \(error)")
            }
        }
    }
    
    func resetValue() {
        wrappedValue = defaultValue
    }
}
