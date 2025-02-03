//
//  File.swift
//  QDataManager
//
//  Created by Junkyu Jeon on 2/2/25.
//

import Foundation

public struct QDataAnyEncodable: Encodable {
    private let _encodeClosure: (Encoder) throws -> Void

    init<T: Encodable>(_ value: T) {
        _encodeClosure = { encoder in
            try value.encode(to: encoder)
        }
    }

    public func encode(to encoder: Encoder) throws {
        try _encodeClosure(encoder)
    }
}

public struct QDataAnyDecodable: Decodable {
    let value: Any

    init<T: Decodable>(_ value: T) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let value = try? container.decode(String.self) {
            self.value = value
        } else if let value = try? container.decode(Int.self) {
            self.value = value
        } else if let value = try? container.decode(Double.self) {
            self.value = value
        } else if let value = try? container.decode(Bool.self) {
            self.value = value
        } else {
            throw DecodingError.typeMismatch(Any.self, DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Unsupported type"
            ))
        }
    }
}

