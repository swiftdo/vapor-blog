//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/18.
//

import Foundation
import LeafKit

enum JsonTagError: Error {
    case missingNameParameter
}

// UnsafeUnescapedLeafTag vs LeafTag 的区别
struct Json2B64Tag: LeafTag {
  func render(_ ctx: LeafContext) throws -> LeafData {
    guard let name = ctx.parameters.first else {
        throw JsonTagError.missingNameParameter
    }
    return LeafData.string(name.jsonString.base64String())
  }
}

struct B642JsonTag: UnsafeUnescapedLeafTag {
  func render(_ ctx: LeafContext) throws -> LeafData {
    guard let name = ctx.parameters.first?.string else {
        throw JsonTagError.missingNameParameter
    }
    return LeafData.string("""
      var decoder = new TextDecoder();
      var decodedString = decoder.decode(new Uint8Array(Array.from(atob(\(name)).map(c => c.charCodeAt(0)))));
      var \(name) = JSON.parse(decodedString);
    """)
  }
    
}

private extension LeafData {
    var jsonString: String {
        guard !isNil else {
            return "null"
        }
        switch celf {
        case .array:
            let items = array!.map { $0.jsonString }
                .joined(separator: ", ")
            return "[\(items)]"
        case .bool:
            return bool! ? "true" : "false"
        case .data:
            return "\"\(data!.base64EncodedString())\""
        case .dictionary:
            let items = dictionary!.map { key, value in "\"\(key)\": \(value.jsonString)" }
                .joined(separator: ", ")
            return "{\(items)}"
        case .double:
            return String(double!)
        case .int:
            return String(int!)
        case .string:
            var encoded: [UInt8] = []
            encodeString(string!, to: &encoded)
            return String(decoding: encoded, as: UTF8.self)
        case .void:
            return "null"
        }
    }
}

// MARK: - String escaping
// The following section is copied from apple/swift-corelibs/foundation.
// https://github.com/apple/swift-corelibs-foundation/blob/cf3320cce8e19da3d2b31bb58522e8b1ef7bd5ef/Sources/Foundation/JSONEncoder.swift#L1109
// Copyright (c) 2014 - 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
private func encodeString(_ string: String, to bytes: inout [UInt8]) {
    bytes.append(UInt8(ascii: "\""))
    let stringBytes = string.utf8
    var startCopyIndex = stringBytes.startIndex
    var nextIndex = startCopyIndex

    while nextIndex != stringBytes.endIndex {
        switch stringBytes[nextIndex] {
        case 0 ..< 32, UInt8(ascii: "\""), UInt8(ascii: "\\"):
            // All Unicode characters may be placed within the
            // quotation marks, except for the characters that MUST be escaped:
            // quotation mark, reverse solidus, and the control characters (U+0000
            // through U+001F).
            // https://tools.ietf.org/html/rfc8259#section-7
            // copy the current range over
            bytes.append(contentsOf: stringBytes[startCopyIndex ..< nextIndex])
            switch stringBytes[nextIndex] {
            case UInt8(ascii: "\""): // quotation mark
                bytes.append(contentsOf: [._backslash, ._quote])
            case UInt8(ascii: "\\"): // reverse solidus
                bytes.append(contentsOf: [._backslash, ._backslash])
            case 0x08: // backspace
                bytes.append(contentsOf: [._backslash, UInt8(ascii: "b")])
            case 0x0C: // form feed
                bytes.append(contentsOf: [._backslash, UInt8(ascii: "f")])
            case 0x0A: // line feed
                bytes.append(contentsOf: [._backslash, UInt8(ascii: "n")])
            case 0x0D: // carriage return
                bytes.append(contentsOf: [._backslash, UInt8(ascii: "r")])
            case 0x09: // tab
                bytes.append(contentsOf: [._backslash, UInt8(ascii: "t")])
            default:
                func valueToAscii(_ value: UInt8) -> UInt8 {
                    switch value {
                    case 0 ... 9:
                        return value + UInt8(ascii: "0")
                    case 10 ... 15:
                        return value - 10 + UInt8(ascii: "a")
                    default:
                        preconditionFailure()
                    }
                }
                bytes.append(UInt8(ascii: "\\"))
                bytes.append(UInt8(ascii: "u"))
                bytes.append(UInt8(ascii: "0"))
                bytes.append(UInt8(ascii: "0"))
                let first = stringBytes[nextIndex] / 16
                let remaining = stringBytes[nextIndex] % 16
                bytes.append(valueToAscii(first))
                bytes.append(valueToAscii(remaining))
            }

            nextIndex = stringBytes.index(after: nextIndex)
            startCopyIndex = nextIndex
        case UInt8(ascii: "/"):
            bytes.append(contentsOf: stringBytes[startCopyIndex ..< nextIndex])
            bytes.append(contentsOf: [._backslash, UInt8(ascii: "/")])
            nextIndex = stringBytes.index(after: nextIndex)
            startCopyIndex = nextIndex
        default:
            nextIndex = stringBytes.index(after: nextIndex)
        }
    }

    // copy everything, that hasn't been copied yet
    bytes.append(contentsOf: stringBytes[startCopyIndex ..< nextIndex])
    bytes.append(UInt8(ascii: "\""))
}

private extension UInt8 {
    static let _space = UInt8(ascii: " ")
    static let _return = UInt8(ascii: "\r")
    static let _newline = UInt8(ascii: "\n")
    static let _tab = UInt8(ascii: "\t")
    
    static let _colon = UInt8(ascii: ":")
    static let _comma = UInt8(ascii: ",")
    
    static let _openbrace = UInt8(ascii: "{")
    static let _closebrace = UInt8(ascii: "}")
    
    static let _openbracket = UInt8(ascii: "[")
    static let _closebracket = UInt8(ascii: "]")
    
    static let _quote = UInt8(ascii: "\"")
    static let _backslash = UInt8(ascii: "\\")
}



