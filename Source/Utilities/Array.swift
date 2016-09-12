//
//  Array.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/8/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

extension Array {
  func keyed(by: (Int, Element) -> AnyHashable) -> Dictionary<AnyHashable, Element> {
    var result = [AnyHashable: Element]()
    for (index, element) in self.enumerated() {
      let key = by(index, element)
      if result[key] != nil {
        fatalError("Attempting to key by elements that have shared key: \(key)")
      }
      result[key] = element
    }
    return result
  }
}
