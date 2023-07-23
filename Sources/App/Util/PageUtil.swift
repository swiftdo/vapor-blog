//
//  File.swift
//  
//
//  Created by laijihua on 2023/7/23.
//

import Foundation
import AnyCodable
import FluentKit

final class PageUtil {
  static func genPageMetadata(pageMeta: PageMetadata?) -> AnyEncodable? {
    guard let pageMeta = pageMeta else {
      return nil
    }
    
    let maxPage = pageMeta.pageCount
    let curPage = pageMeta.page

    var showMaxMore: Bool = true
    var showMinMore: Bool = true
    var showPages: [Int] = []
    
    if (maxPage <= 3) {
      showMaxMore = false
      showMinMore = false
      showPages = [Int](1...maxPage)
    } else {
      if(curPage < 3) {
        showMinMore = false
        showMaxMore = true
      }
      else if (curPage > maxPage - 3) {
        showMinMore = true
        showMaxMore = false
      }
      
      if (curPage == 1) {
        showPages = [curPage, curPage + 1, curPage + 2]
      } else if (curPage == maxPage) {
        showPages = [curPage - 2, curPage - 1, curPage]
      } else {
        showPages = [curPage - 1,curPage, curPage + 1]
      }
    }
    
    return [
      "maxPage": maxPage,
      "minPage": 1,
      "curPage": curPage,
      "showMinMore": showMinMore,
      "showMaxMore": showMaxMore,
      "showPages": showPages,
      "total": pageMeta.total,
      "page":pageMeta.page,
      "per": pageMeta.per,
      "perOptions": [
        ["value": "10", "label": "10条/页"],
        ["value": "20", "label": "20条/页"],
        ["value": "30", "label": "30条/页"],
        ["value": "50", "label": "50条/页"]
      ],
    ]
  }
}
