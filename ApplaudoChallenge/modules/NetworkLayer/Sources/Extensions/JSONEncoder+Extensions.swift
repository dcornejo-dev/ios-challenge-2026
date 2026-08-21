//
//  JSONEncoder+Extensions.swift
//  ApplaudoChallenge
//
//  Created by Christian Rivera on 25/3/26.
//

import Foundation

// MARK: - JSONEncoder Extension
extension JSONEncoder {
    // MARK: - Encode as Dictionary
    /// Converts an `Encodable` value into a `[String: Any]` dictionary.
    /// Useful for building request parameter dictionaries from typed models.
    public func encodeAsDictionary<T: Encodable>(_ encode: T) -> [String: Any]? {
        // Encode the object to JSON data first; returns nil if the object fails to encode.
        guard let data = try? self.encode(encode) else {
            return nil
        }

        // Deserialize the JSON bytes into a raw dictionary representation.
        guard let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        else {
            return nil
        }

        return dictionary
    }
}
