//
//  StyleProperties.swift
//  TemplateKit
//
//  Created by Matias Cudich on 10/5/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public struct StyleProperties: RawProperties, Model, Equatable {
  public var backgroundColor: UIColor?
  public var borderColor: UIColor?
  public var borderWidth: CGFloat?
  public var cornerRadius: CGFloat?
  public var opacity: CGFloat?

  public init() {}

  public init(_ properties: [String : Any]) {
    backgroundColor = properties.color("backgroundColor")
    borderColor = properties.color("borderColor")
    borderWidth = properties.cast("borderWidth")
    cornerRadius = properties.cast("cornerRadius")
    opacity = properties.cast("opacity")
  }

  public mutating func merge(_ other: StyleProperties) {
    merge(&backgroundColor, other.backgroundColor)
    merge(&borderColor, other.borderColor)
    merge(&borderWidth, other.borderWidth)
    merge(&cornerRadius, other.cornerRadius)
    merge(&opacity, other.opacity)
  }
}

public func ==(lhs: StyleProperties, rhs: StyleProperties) -> Bool {
  return lhs.backgroundColor == rhs.backgroundColor && lhs.borderColor == rhs.borderColor && lhs.borderWidth == rhs.borderWidth && lhs.cornerRadius == rhs.cornerRadius && lhs.opacity == rhs.opacity
}
