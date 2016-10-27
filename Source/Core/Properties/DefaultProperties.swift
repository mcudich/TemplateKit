//
//  DefaultProperties.swift
//  TemplateKit
//
//  Created by Matias Cudich on 10/5/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public struct DefaultProperties: Properties {
  public var core = CoreProperties()
  public var textStyle = TextStyleProperties()

  public init() {}

  public init(_ properties: [String: Any]) {
    core = CoreProperties(properties)
    textStyle = TextStyleProperties(properties)
  }

  public mutating func merge(_ other: DefaultProperties) {
    core.merge(other.core)
    textStyle.merge(other.textStyle)
  }
}

public func ==(lhs: DefaultProperties, rhs: DefaultProperties) -> Bool {
  return lhs.equals(otherProperties: rhs)
}
