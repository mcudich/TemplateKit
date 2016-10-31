//
//  Dictionary.swift
//  TemplateKit
//
//  Created by Matias Cudich on 8/10/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public extension Dictionary {
  mutating func merge(with dictionary: Dictionary) {
    for (key, value) in dictionary {
      self[key] = value
    }
  }

  func merged(with dictionary: Dictionary) -> Dictionary {
    var copy = self
    copy.merge(with: dictionary)
    return copy
  }
}

func ==<K: Equatable, V: Equatable>(lhs: [K: V]?, rhs: [K: V]?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l == r
  case (.none, .none):
    return true
  default:
    return false
  }
}
