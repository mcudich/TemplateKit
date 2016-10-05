//
//  GestureProperties.swift
//  TemplateKit
//
//  Created by Matias Cudich on 10/5/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public struct GestureProperties: RawProperties, Model, Equatable {
  var onTap: Selector?
  var onPress: Selector?
  var onDoubleTap: Selector?

  public init() {}

  public init(_ properties: [String : Any]) {
    onTap = properties.cast("onTap")
    onPress = properties.cast("onPress")
    onDoubleTap = properties.cast("onDoubleTap")
  }

  public mutating func merge(_ other: GestureProperties) {
    merge(&onTap, other.onTap)
    merge(&onPress, other.onPress)
    merge(&onDoubleTap, other.onDoubleTap)
  }
}

public func ==(lhs: GestureProperties, rhs: GestureProperties) -> Bool {
  return lhs.onTap == rhs.onTap
}
