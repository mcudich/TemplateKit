//
//  IdentifierProperties.swift
//  TemplateKit
//
//  Created by Matias Cudich on 10/5/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public struct IdentifierProperties: RawProperties, Model, Equatable {
  var key: String?
  var id: String?
  var classNames: [String]?

  public init() {}

  public init(_ properties: [String : Any]) {
    key = properties.cast("key")
    id = properties.cast("id")
    if let classNames: String = properties.cast("classNames") {
      self.classNames = classNames.components(separatedBy: " ")
    }
  }

  public mutating func merge(_ other: IdentifierProperties) {
    merge(&key, other.key)
    merge(&id, other.id)
    merge(&classNames, other.classNames)
  }
}

public func ==(lhs: IdentifierProperties, rhs: IdentifierProperties) -> Bool {
  return lhs.key == rhs.key && lhs.id == rhs.id && lhs.classNames == rhs.classNames
}
