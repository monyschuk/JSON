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

public enum JSONDecodingError: Error {
    case unrecognizedKey(String)
    case incorrectValueType(JSON)
}

public struct JSONEncoderOf<T> {
    public var encode: (T)->JSON
}

extension JSONEncoderOf where T: JSONEncoding {
    public init() {
        encode = { item in
            item.jsonValue()
        }
    }
    
    public func polymorphically(key: String, map: [String:T.Type]) -> JSONEncoderOf {
        return JSONEncoderOf<T> { item in
            let type = Mirror(reflecting:item).subjectType
            let value = map.first(where:{ $0.value == type })?.key
            
            var json = item.jsonValue()
            if let value = value {
                json[key] = .string(value)
            }
            return json
        }
    }
}

extension JSONEncoderOf {
    public func zeroOrMore() -> JSONEncoderOf<[T]> {
        return JSONEncoderOf<[T]> { item in
            return .array(item.map { self.encode($0) })
        }
    }
    
    public func orNil() -> JSONEncoderOf<T?> {
        return JSONEncoderOf<T?> { item in
            if let item = item {
                return self.encode(item)
            } else {
                return .null
            }
        }
    }
}

public struct JSONDecoderOf<T> {
    public var decode: (JSON)throws->T
}

extension JSONDecoderOf where T: JSONDecoding {
    public init() {
        decode = { json in
            try T(jsonValue: json)
        }
    }
    
    public func polymorphically(key: String, map: [String:T.Type]) -> JSONDecoderOf {
        return JSONDecoderOf<T> { json in
            if let value = json[key].asString, let mappedType = map[value] {
                return try mappedType.init(jsonValue: json)
            } else {
                throw JSONDecodingError.incorrectValueType(json)
            }
        }
    }
}

extension JSONDecoderOf {
    public func map<U>(transform: @escaping (T)->U) -> JSONDecoderOf<U> {
        return JSONDecoderOf<U> { json in
            transform(try self.decode(json))
        }
    }
    
    public func zeroOrMore() -> JSONDecoderOf<[T]> {
        return JSONDecoderOf<[T]> { json in
            if let array = json.asArray {
                return try array.map { try self.decode($0) }
            } else {
                throw JSONDecodingError.incorrectValueType(json)
            }
        }
    }
    public func oneOrMore() -> JSONDecoderOf<[T]> {
        return JSONDecoderOf<[T]> { json in
            if let array = json.asArray, !array.isEmpty {
                return try array.map { try self.decode($0) }
            } else {
                throw JSONDecodingError.incorrectValueType(json)
            }
        }
    }
    
    public func orNil() -> JSONDecoderOf<T?> {
        return JSONDecoderOf<T?> { json in
            if json.isNull {
                return nil
            } else {
                return try self.decode(json)
            }
        }
    }
    
    public func ifNull(use value: T) -> JSONDecoderOf<T> {
        return JSONDecoderOf<T> { json in
            if json.isNull {
                return value
            } else {
                return try self.decode(json)
            }
        }
    }
}

extension Int: JSONEncoding, JSONDecoding {
    public func jsonValue() -> JSON {
        return .number(Double(self))
    }
    
    public init(jsonValue: JSON) throws {
        if let value = jsonValue.asInt {
            self = value
        } else {
            throw JSONDecodingError.incorrectValueType(jsonValue)
        }
    }
    
    public static let encoder = JSONEncoderOf<Int>()
    public static let decoder = JSONDecoderOf<Int>()
}

extension Float: JSONEncoding, JSONDecoding {
    public func jsonValue() -> JSON {
        return .number(Double(self))
    }
    
    public init(jsonValue: JSON) throws {
        if let value = jsonValue.asFloat {
            self = value
        } else {
            throw JSONDecodingError.incorrectValueType(jsonValue)
        }
    }
    
    public static let encoder = JSONEncoderOf<Float>()
    public static let decoder = JSONDecoderOf<Float>()
}

extension CGFloat: JSONEncoding, JSONDecoding {
    public func jsonValue() -> JSON {
        return .number(Double(self))
    }
    
    public init(jsonValue: JSON) throws {
        if let value = jsonValue.asCGFloat {
            self = value
        } else {
            throw JSONDecodingError.incorrectValueType(jsonValue)
        }
    }
    
    public static let encoder = JSONEncoderOf<CGFloat>()
    public static let decoder = JSONDecoderOf<CGFloat>()
}

extension Double: JSONEncoding, JSONDecoding {
    public func jsonValue() -> JSON {
        return .number(self)
    }
    
    public init(jsonValue: JSON) throws {
        if let value = jsonValue.asDouble {
            self = value
        } else {
            throw JSONDecodingError.incorrectValueType(jsonValue)
        }
    }
    
    public static let encoder = JSONEncoderOf<Double>()
    public static let decoder = JSONDecoderOf<Double>()
}

extension Bool: JSONEncoding, JSONDecoding {
    public func jsonValue() -> JSON {
        return .bool(self)
    }
    
    public init(jsonValue: JSON) throws {
        if let value = jsonValue.asBool {
            self = value
        } else {
            throw JSONDecodingError.incorrectValueType(jsonValue)
        }
    }
    
    public static let encoder = JSONEncoderOf<Bool>()
    public static let decoder = JSONDecoderOf<Bool>()
}

extension String: JSONEncoding, JSONDecoding {
    public func jsonValue() -> JSON {
        return .string(self)
    }
    
    public init(jsonValue: JSON) throws {
        if let value = jsonValue.asString {
            self = value
        } else {
            throw JSONDecodingError.incorrectValueType(jsonValue)
        }
    }
    
    public static let encoder = JSONEncoderOf<String>()
    public static let decoder = JSONDecoderOf<String>()
}

extension JSON {
    // convenience function which makes decoding read a bit more cleanly
    public func decode<T>(using decoder: JSONDecoderOf<T>) throws -> T {
        return try decoder.decode(self)
    }
}
