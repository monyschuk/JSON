//
//  JSONCoding.swift
//  JSON
//
//  Created by Mark Onyschuk on 2016-10-13.
//  Copyright © 2016 Mark Onyschuk. All rights reserved.
//

import Foundation


public protocol JSONEncoding {
    func jsonValue() -> JSON
}

public protocol JSONDecoding {
    init(jsonValue: JSON) throws
}

public protocol JSONCoding: JSONEncoding, JSONDecoding {}

public enum JSONDecodingError: Error {
    case unrecognizedKey(String)
    case unrecognizedValue(JSON)
}

public struct JSONObjectMap {
    public let key:    String
    public let values: [String: JSONCoding.Type]
    
    public init(key: String, values: [String:JSONCoding.Type]) {
        self.key = key
        self.values = values
    }
}

public struct JSONEncoder {
    public static func encode<T: JSONEncoding>(_ item: T) -> JSON {
        return item.jsonValue()
    }
    
    public static func encode<T: JSONEncoding>(_ items: [T]) -> JSON {
        return JSON.array(items.map { $0.jsonValue() })
    }
    
    public static func encode<T: JSONEncoding>(_ dict: [String:T]) -> JSON {
        var encoded = [String:JSON]()
        for (k, v) in dict {
            encoded[k] = v.jsonValue()
        }
        return JSON.object(encoded)
    }
    
    public static func encode(map: JSONObjectMap, item: JSONEncoding) -> JSON {
        var json = item.jsonValue()
        let type = Mirror(reflecting: item).subjectType
        
        for (key, val) in map.values {
            if val == type {
                json[map.key] = .string(key)
                break
            }
        }
        return json
    }
    
    public static func encode(map: JSONObjectMap, items: [JSONEncoding]) -> JSON {
        return .array(items.map { encode(map: map, item: $0) })
    }
}

public struct JSONDecoder {
    public static func decode<T: JSONDecoding>(_ json: JSON) throws -> T {
        return try T(jsonValue: json)
    }
    
    public static func decode<T: JSONDecoding>(_ json: JSON) throws -> [T] {
        switch json {
        case .array(let values):
            return try values.map { try T(jsonValue: $0) }
        default:
            throw JSONDecodingError.unrecognizedValue(json)
        }
    }
    
    public static func decode<T: JSONDecoding>(_ json: JSON) throws -> [String:T] {
        switch json {
        case .object(let dict):
            var decoded = [String:T]()
            for (k, v) in dict {
                decoded[k] = try T(jsonValue: v)
            }
            return decoded
        default:
            throw JSONDecodingError.unrecognizedValue(json)
        }
    }
    
    public static func decode(map: JSONObjectMap, object json: JSON) throws -> JSONDecoding {
        guard let v = json[map.key].asString else {
            throw JSONDecodingError.unrecognizedKey(map.key)
        }
        guard let type = map.values[v] else {
            throw JSONDecodingError.unrecognizedKey(map.key)
        }
        
        return try type.init(jsonValue: json)
    }
    
    public static func decode(map: JSONObjectMap, array json: JSON) throws -> [JSONDecoding] {
        switch json {
        case .array(let values):
            return try values.map { try decode(map: map, object: $0) }
        default:
            throw JSONDecodingError.unrecognizedValue(json)
        }
    }
}
