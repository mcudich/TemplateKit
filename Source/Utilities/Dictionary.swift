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

  func get<T>(_ key: Key) -> T? {
    return self[key] as? T
  }

  func get<T>(_ key: Key, defaultValue: T) -> T {
    return get(key) ?? defaultValue
  }
}
