//
//  File.swift
//  QDataManager
//
//  Created by Junkyu Jeon on 2/18/25.
//

import Foundation
import CryptoKit

public struct QAESCryptoHelper {
    private static let keyTag = "com.qdatamanager.aesKey"

    private static func _getOrCreateKey() -> SymmetricKey {
        if let storedKey = _loadKeyFromKeychain() {
            return storedKey
        } else {
            let newKey = SymmetricKey(size: .bits256)
            _saveKeyToKeychain(newKey)
            return newKey
        }
    }

    private static func _loadKeyFromKeychain() -> SymmetricKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keyTag,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return SymmetricKey(data: data)
        }
        return nil
    }

    private static func _saveKeyToKeychain(_ key: SymmetricKey) {
        let keyData = key.withUnsafeBytes { Data($0) }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keyTag,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    public static func encrypt(_ data: Data) throws -> Data {
        let key = _getOrCreateKey()
        let sealedBox = try AES.GCM.seal(data, using: key)
        return sealedBox.combined!
    }

    public static func decrypt(_ encryptedData: Data) throws -> Data {
        let key = _getOrCreateKey()
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        return try AES.GCM.open(sealedBox, using: key)
    }
}

