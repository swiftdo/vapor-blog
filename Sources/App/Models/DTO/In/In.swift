//
//  File.swift
//  
//
//  Created by laijihua on 2023/6/13.
//

import Vapor

protocol In: Content {}


// 特殊的整形，因为表单提交的时候，值一般都是字符串。
enum SpecInt: Codable {
  case int(Int)
  case string(String)
  
  // 强制转为整形
  func castInt(def: Int = 1) -> Int {
    switch self {
      case .int(let v): return v
      case .string(let s): return Int(s) ?? def
    }
  }

  init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      if let intValue = try? container.decode(Int.self) {
          self = .int(intValue)
      } else if let stringValue = try? container.decode(String.self) {
          self = .string(stringValue)
      } else {
          throw DecodingError.typeMismatch(SpecInt.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Value cannot be decoded as Int or String."))
      }
  }

  func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      switch self {
      case .int(let intValue):
          try container.encode(intValue)
      case .string(let stringValue):
          try container.encode(stringValue)
      }
  }
}
