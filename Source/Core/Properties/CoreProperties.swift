//
//  CoreProperties.swift
//  TemplateKit
//
//  Created by Matias Cudich on 10/5/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public struct CoreProperties: RawProperties, Equatable {
  public var identifier = IdentifierProperties()
  public var layout = LayoutProperties()
  public var style = StyleProperties()
  public var gestures = GestureProperties()

  public init() {}

  public init(_ properties: [String : Any]) {
    identifier = IdentifierProperties(properties)
    layout = LayoutProperties(properties)
    style = StyleProperties(properties)
    gestures = GestureProperties(properties)
  }

  public mutating func merge(_ other: CoreProperties) {
    identifier.merge(other.identifier)
    layout.merge(other.layout)
    style.merge(other.style)
    gestures.merge(other.gestures)
  }
}

public func ==(lhs: CoreProperties, rhs: CoreProperties) -> Bool {
  return lhs.identifier == rhs.identifier && lhs.layout == lhs.layout && lhs.style == rhs.style && lhs.gestures == rhs.gestures
}
