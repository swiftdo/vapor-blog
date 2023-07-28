//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/24.
//

import Foundation

struct InSearchPost: In {
  let categoryId: UUID?
  let tagId: UUID?
  let searchKey: String? // 搜索的词
  let listFor: String? // tag, category, search
}
