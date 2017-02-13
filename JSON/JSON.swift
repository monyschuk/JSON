//
//  JSON.swift
//  JSON
//
//  Created by Mark Onyschuk on 2016-10-16.
//  Copyright © 2016 Mark Onyschuk. All rights reserved.
//

import Foundation

public enum JSONError: Error {
    case invalidURL(URL)
}

public enum JSON {
    case null
    
    case bool(Bool)
    case string(String)
    case number(Double)
    
    case array([JSON])
    case object([String:JSON])
    
    public init() {
        self = .null
    }
}

extension JSON:Equatable {
    public static func ==(lhs: JSON, rhs: JSON) -> Bool {
        switch (lhs, rhs) {
        case (.null, .null):                    return true
            
        case let (.bool(v1), .bool(v2)):        return v1 == v2
        case let (.string(v1), .string(v2)):    return v1 == v2
        case let (.number(v1), .number(v2)):    return v1 == v2
            
        case let (.array(v1), .array(v2)):      return v1 == v2
        case let (.object(v1), .object(v2)):    return v1 == v2
            
        default:                                return false
        }
    }
}

extension JSON: RawRepresentable {
    private struct ObjCEncodings {
        static let bool = NSNumber(value: true).objCType
    }
    
    public var rawValue: Any {
        switch self {
        case .null:
            return NSNull()
            
        case let .bool(value):
            return value
            
        case let .string(value):
            return value
            
        case let .number(value):
            return value
            
        case let .array(value):
            return value.map { $0.rawValue }
            
        case let .object(value):
            var raw = [String:Any]()
            for (k, v) in value {
                raw[k] = v.rawValue
            }
            return raw
        }
    }
    
    public init?(rawValue: Any) {
        switch rawValue {
        case is NSNull:
            self = .null
            
        case let value as NSNumber:
            
            // NOTE: under the hood, JSONSerialization instantiates
            // NSNumber objects to represent all numerics including booleans.
            //
            // The underlying type of the numeric can be identified using its
            // associated ObjC type encoding. Bool is the only type we're
            // interested in differentiating.
            
            switch value.objCType {
            case JSON.ObjCEncodings.bool:
                self = .bool(value.boolValue)
            default:
                self = .number(value.doubleValue)
            }
            
        case let value as NSString:
            self = .string(value as String)
            
        case let value as [Any]:
            self = .array(value.flatMap { JSON(rawValue: $0) })
            
        case let value as [String:Any]:
            var unraw = [String:JSON]()
            for (k, v) in value {
                if let v = JSON(rawValue: v) {
                    unraw[k] = v
                }
            }
            self = .object(unraw)
            
        default:
            return nil
        }
    }
}

extension JSON {
    public enum PrintOptions {
        case pretty
        case compact
    }
    
    public func print(options: PrintOptions = .compact) -> String {
        switch self {
        case .null:
            return "null"
        case let .bool(value):
            return "\(value)"
        case let .number(value):
            return "\(value)"
        case let .string(value):
            return "\(value)"
        default:
            let writingOptions: JSONSerialization.WritingOptions =
                (options == .pretty)
                    ? [.prettyPrinted]
                    : []
            
            if  let data = try? JSON.write(self, options: writingOptions),
                let text = String(data: data, encoding: String.Encoding.utf8) {
                return text
            } else {
                return ""
            }
        }
    }
}

//extension JSON: CustomStringConvertible {
//public var description: String {
//    return print(options: .pretty)
//}
//}

extension JSON {
    public var isNull: Bool {
        switch self {
        case .null:                 return true
        default:                    return false
        }
    }
    
    public var asBool: Bool? {
        switch self {
        case let .bool(value):       return value
        default:                     return nil
        }
    }
    
    public var asInt: Int? {
        switch self {
        case let .number(value):    return Int(value)
        default:                    return nil
        }
    }
    
    public var asUInt: UInt? {
        switch self {
        case let .number(value):    return UInt(value)
        default:                    return nil
        }
    }

    public var asInt64: Int64? {
        switch self {
        case let .number(value):    return Int64(value)
        default:                    return nil
        }
    }
    
    public var asUInt64: UInt64? {
        switch self {
        case let .number(value):    return UInt64(value)
        default:                    return nil
        }
    }
  
    public var asFloat: Float? {
        switch self {
        case let .number(value):    return Float(value)
        default:                    return nil
        }
    }
    
    public var asCGFloat: CGFloat? {
        switch self {
        case let .number(value):    return CGFloat(value)
        default:                    return nil
        }
    }
    
    public var asDouble: Double? {
        switch self {
        case let .number(value):    return Double(value)
        default:                    return nil
        }
    }
    
    public var asString: String? {
        switch self {
        case let .string(value):    return value
        default:                    return nil
        }
    }
    
    public var asArray: [JSON]? {
        switch self {
        case let .array(values):    return values
        default:                    return nil
        }
    }
    
    public var asObject: [String:JSON]? {
        switch self {
        case let .object(values):   return values
        default:                    return nil
        }
    }
}

// dictionary interface
extension JSON {
    public subscript(key: String) -> JSON {
        get {
            switch self {
            case let .object(value):
                return value[key] ?? .null
            default:
                return .null
            }
        }
        mutating set(newValue) {
            switch self {
            case let .object(value):
                var value = value
                value[key] = newValue
                self = .object(value)
                
            default:
                self = .object([key: newValue])
            }
        }
    }
    
    public var keys: [String] {
        switch self {
        case let .object(value):
            return value.map { $0.key }
        default:
            return []
        }
    }
    public var values: [JSON] {
        switch self {
        case let .object(value):
            return value.map { $0.value }
        default:
            return []
        }
    }
}

// array interface
extension JSON {
    public subscript(index: Int) -> JSON {
        get {
            switch self {
            case let .array(value):
                return (0..<value.count).contains(index) ? value[index] : .null
            default:
                return .null
            }
        }
        mutating set(newValue) {
            switch self {
            case let .array(value):
                var value = value
                if index < value.startIndex {
                    value.insert(newValue, at: 0)
                } else if index >= value.count {
                    value.append(newValue)
                } else {
                    value[index] = newValue
                }
                self = .array(value)
            default:
                self = .array([newValue])
            }
        }
    }
    
    public var count: Int {
        switch self {
        case let .array(value):
            return value.count
        default:
            return 0
        }
    }
    
    public mutating func append(_ value: JSON) {
        self[count] = value
    }
}

extension JSON {
    public static func read(data: Data) throws -> JSON {
        return JSON(rawValue: try JSONSerialization.jsonObject(with: data, options: []))!
    }
    
    public static func read(url: URL) throws -> JSON {
        guard let stream = InputStream(url: url) else { throw JSONError.invalidURL(url) }
        
        stream.open()
        defer { stream.close() }
        
        return JSON(rawValue: try JSONSerialization.jsonObject(with: stream, options: []))!
    }
    
    public static func write(_ json: JSON, options: JSONSerialization.WritingOptions = []) throws -> Data {
        return try JSONSerialization.data(withJSONObject: json.rawValue, options: options)
    }
}
