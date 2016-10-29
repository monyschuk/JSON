//
//  JSONCodingTypes.swift
//  JSON
//
//  Created by Mark Onyschuk on 2016-10-29.
//  Copyright © 2016 Mark Onyschuk. All rights reserved.
//

import Foundation

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

extension Data: JSONEncoding, JSONDecoding {
    public func jsonValue() -> JSON {
        return .string(base64EncodedString())
    }
    public init(jsonValue: JSON) throws {
        if let value = jsonValue.asString, let dataValue = Data(base64Encoded: value) {
            self = dataValue
        } else {
            throw JSONDecodingError.incorrectValueType(jsonValue)
        }
    }

    public static let encoder = JSONEncoderOf<Data>()
    public static let decoder = JSONDecoderOf<Data>()
}

extension CGPoint: JSONEncoding, JSONDecoding {
    public func jsonValue() -> JSON {
        var json = JSON()

        json["x"] = x.jsonValue()
        json["y"] = y.jsonValue()

        return json
    }
    public init(jsonValue: JSON) throws {
        self.x = try jsonValue["x"].decode(using: CGFloat.decoder)
        self.y = try jsonValue["y"].decode(using: CGFloat.decoder)
    }

    public static let encoder = JSONEncoderOf<CGPoint>()
    public static let decoder = JSONDecoderOf<CGPoint>()
}

extension CGSize: JSONEncoding, JSONDecoding {
    public func jsonValue() -> JSON {
        var json = JSON()

        json["w"] = width.jsonValue()
        json["h"] = height.jsonValue()

        return json
    }
    public init(jsonValue: JSON) throws {
        self.width = try jsonValue["width"].decode(using: CGFloat.decoder)
        self.height = try jsonValue["height"].decode(using: CGFloat.decoder)
    }

    public static let encoder = JSONEncoderOf<CGSize>()
    public static let decoder = JSONDecoderOf<CGSize>()
}

extension CGVector: JSONEncoding, JSONDecoding {
    public func jsonValue() -> JSON {
        var json = JSON()

        json["dx"] = dx.jsonValue()
        json["dy"] = dy.jsonValue()

        return json
    }
    public init(jsonValue: JSON) throws {
        dx = try jsonValue["dx"].decode(using: CGFloat.decoder)
        dy = try jsonValue["dy"].decode(using: CGFloat.decoder)
    }
}

extension CGRect: JSONEncoding, JSONDecoding {
    public func jsonValue() -> JSON {
        var json = JSON()

        json["x"] = origin.x.jsonValue()
        json["y"] = origin.y.jsonValue()
        json["w"] = size.width.jsonValue()
        json["h"] = size.height.jsonValue()

        return json
    }
    public init(jsonValue: JSON) throws {
        origin = CGPoint(
            x:      try jsonValue["x"].decode(using: CGFloat.decoder),
            y:      try jsonValue["y"].decode(using: CGFloat.decoder)
        )
        size   = CGSize(
            width:  try jsonValue["w"].decode(using: CGFloat.decoder),
            height: try jsonValue["h"].decode(using: CGFloat.decoder)
        )
    }

    public static let encoder = JSONEncoderOf<CGRect>()
    public static let decoder = JSONDecoderOf<CGRect>()
}

extension EdgeInsets: JSONEncoding, JSONDecoding {
    public func jsonValue() -> JSON {
        var json = JSON()

        json["t"] = top.jsonValue()
        json["l"] = left.jsonValue()
        json["r"] = right.jsonValue()
        json["b"] = bottom.jsonValue()

        return json
    }
    public init(jsonValue: JSON) throws {
        top     = try jsonValue["t"].decode(using: CGFloat.decoder)
        left    = try jsonValue["l"].decode(using: CGFloat.decoder)
        right   = try jsonValue["r"].decode(using: CGFloat.decoder)
        bottom  = try jsonValue["b"].decode(using: CGFloat.decoder)
    }

    public static let encoder = JSONEncoderOf<EdgeInsets>()
    public static let decoder = JSONDecoderOf<EdgeInsets>()
}
