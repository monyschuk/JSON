//
//  JSONCodingTypes.swift
//  JSON
//
//  Created by Mark Onyschuk on 2016-10-29.
//  Copyright © 2016 Mark Onyschuk. All rights reserved.
//

import Foundation

extension Int: JSONCoding {
    public func jsonValue() -> JSON {
        return .number(Double(self))
    }
    
    public init(jsonValue: JSON) throws {
        if let value = jsonValue.asInt {
            self = value
        } else {
            throw JSONDecodingError.unrecognizedValue(jsonValue)
        }
    }
}

extension UInt: JSONCoding {
    public func jsonValue() -> JSON {
        return .number(Double(self))
    }
    
    public init(jsonValue: JSON) throws {
        if let value = jsonValue.asUInt {
            self = value
        } else {
            throw JSONDecodingError.unrecognizedValue(jsonValue)
        }
    }
}

extension Float: JSONCoding {
    public func jsonValue() -> JSON {
        return .number(Double(self))
    }
    
    public init(jsonValue: JSON) throws {
        if let value = jsonValue.asFloat {
            self = value
        } else {
            throw JSONDecodingError.unrecognizedValue(jsonValue)
        }
    }
}

extension CGFloat: JSONCoding {
    public func jsonValue() -> JSON {
        return .number(Double(self))
    }
    
    public init(jsonValue: JSON) throws {
        if let value = jsonValue.asCGFloat {
            self = value
        } else {
            throw JSONDecodingError.unrecognizedValue(jsonValue)
        }
    }
}

extension Double: JSONCoding {
    public func jsonValue() -> JSON {
        return .number(self)
    }
    
    public init(jsonValue: JSON) throws {
        if let value = jsonValue.asDouble {
            self = value
        } else {
            throw JSONDecodingError.unrecognizedValue(jsonValue)
        }
    }
}

extension Bool: JSONCoding {
    public func jsonValue() -> JSON {
        return .bool(self)
    }
    
    public init(jsonValue: JSON) throws {
        if let value = jsonValue.asBool {
            self = value
        } else {
            throw JSONDecodingError.unrecognizedValue(jsonValue)
        }
    }
}

extension String: JSONCoding {
    public func jsonValue() -> JSON {
        return .string(self)
    }
    
    public init(jsonValue: JSON) throws {
        if let value = jsonValue.asString {
            self = value
        } else {
            throw JSONDecodingError.unrecognizedValue(jsonValue)
        }
    }
}

extension Data: JSONCoding {
    public func jsonValue() -> JSON {
        return .string(base64EncodedString())
    }
    public init(jsonValue: JSON) throws {
        if let value = jsonValue.asString, let dataValue = Data(base64Encoded: value) {
            self = dataValue
        } else {
            throw JSONDecodingError.unrecognizedValue(jsonValue)
        }
    }
}

extension CGPoint: JSONCoding {
    public func jsonValue() -> JSON {
        var json = JSON()
        
        json["x"] = x.jsonValue()
        json["y"] = y.jsonValue()
        
        return json
    }
    public init(jsonValue: JSON) throws {
        self.x = try JSONDecoder.decode(jsonValue["x"])
        self.y = try JSONDecoder.decode(jsonValue["y"])
    }
}

extension CGSize: JSONCoding {
    public func jsonValue() -> JSON {
        var json = JSON()
        
        json["w"] = width.jsonValue()
        json["h"] = height.jsonValue()
        
        return json
    }
    public init(jsonValue: JSON) throws {
        self.width = try JSONDecoder.decode(jsonValue["w"])
        self.height = try JSONDecoder.decode(jsonValue["h"])
    }
}

extension CGVector: JSONCoding {
    public func jsonValue() -> JSON {
        var json = JSON()
        
        json["dx"] = dx.jsonValue()
        json["dy"] = dy.jsonValue()
        
        return json
    }
    
    public init(jsonValue: JSON) throws {
        self.dx = try JSONDecoder.decode(jsonValue["dx"])
        self.dy = try JSONDecoder.decode(jsonValue["dy"])
    }
}

extension CGRect: JSONCoding {
    public func jsonValue() -> JSON {
        var json = JSON()
        
        json["x"] = origin.x.jsonValue()
        json["y"] = origin.y.jsonValue()
        json["w"] = size.width.jsonValue()
        json["h"] = size.height.jsonValue()
        
        return json
    }
    
    public init(jsonValue: JSON) throws {
        self.origin = CGPoint(
            x:      try JSONDecoder.decode(jsonValue["x"]) as CGFloat,
            y:      try JSONDecoder.decode(jsonValue["y"])
        )
        self.size   = CGSize(
            width:  try JSONDecoder.decode(jsonValue["w"]) as CGFloat,
            height: try JSONDecoder.decode(jsonValue["h"])
        )
    }
}

extension EdgeInsets: JSONCoding {
    public func jsonValue() -> JSON {
        var json = JSON()
        
        json["t"] = top.jsonValue()
        json["l"] = left.jsonValue()
        json["r"] = right.jsonValue()
        json["b"] = bottom.jsonValue()
        
        return json
    }
    public init(jsonValue: JSON) throws {
        self.top     = try JSONDecoder.decode(jsonValue["t"])
        self.left    = try JSONDecoder.decode(jsonValue["l"])
        self.right   = try JSONDecoder.decode(jsonValue["r"])
        self.bottom  = try JSONDecoder.decode(jsonValue["b"])
    }
}
