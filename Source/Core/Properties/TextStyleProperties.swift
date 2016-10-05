//
//  TextStyleProperties.swift
//  TemplateKit
//
//  Created by Matias Cudich on 10/5/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public struct TextStyleProperties: RawProperties, Equatable {
  public var fontName: String?
  public var fontSize: CGFloat?
  public var color: UIColor?
  public var lineBreakMode: NSLineBreakMode?
  public var textAlignment: NSTextAlignment?

  public init() {}

  public init(_ properties: [String : Any]) {
    fontName = properties.cast("fontName")
    fontSize = properties.cast("fontSize")
    color = properties.color("color")
    lineBreakMode = properties.cast("lineBreakMode")
    textAlignment = properties.cast("textAlignment")
  }

  public mutating func merge(_ other: TextStyleProperties) {
    merge(&fontName, other.fontName)
    merge(&fontSize, other.fontSize)
    merge(&color, other.color)
    merge(&lineBreakMode, other.lineBreakMode)
    merge(&textAlignment, other.textAlignment)
  }
}

public func ==(lhs: TextStyleProperties, rhs: TextStyleProperties) -> Bool {
  return lhs.fontName == rhs.fontName && lhs.fontSize == rhs.fontSize && lhs.color == rhs.color && lhs.lineBreakMode == rhs.lineBreakMode && lhs.textAlignment == rhs.textAlignment
}
