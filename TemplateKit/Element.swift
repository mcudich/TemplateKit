//
//  Element.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/3/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public struct Element {
  let type: ElementRepresentable
  let properties: [String: Any]
  let children: [Element]?

  public init(_ type: ElementRepresentable, _ properties: [String: Any] = [:], _ children: [Element]? = nil) {
    self.type = type
    self.properties = properties
    self.children = children
  }

  public func get<T>(_ key: String) -> T? {
    return properties[key] as? T
  }
}
