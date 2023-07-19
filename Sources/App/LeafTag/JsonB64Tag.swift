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
      var decodedString = decoder.decode(new Uint8Array(Array.from(atob(\(name))).map(c => c.charCodeAt(0))));
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
          let encoder = JSONEncoder()
          do {
            let encData = try encoder.encode(string!)
            return String(data: encData, encoding: .utf8) ?? ""
          } catch {
            return ""
          }
        case .void:
            return "null"
        }
    }
}
