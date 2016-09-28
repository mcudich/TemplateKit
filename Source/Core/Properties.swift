//
//  Properties.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/19/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public protocol RawPropertiesReceiver {
  init(_ properties: [String: Any])
  mutating func merge(_ other: Self)

  mutating func merge<T>(_ value: inout T?, _ newValue: T?)
}

public extension RawPropertiesReceiver {
  public mutating func merge<T>(_ value: inout T?, _ newValue: T?) {
    if let newValue = newValue {
      value = newValue
    }
  }
}

public protocol Properties: RawPropertiesReceiver, Model {
  var key: String? { get set }
  var id: String? { get set }
  var classNames: [String]? { get set }

  init()
}

public struct StyleProperties: RawPropertiesReceiver, Model, Equatable {
  public var backgroundColor: UIColor?
  public var borderColor: UIColor?
  public var borderWidth: CGFloat?
  public var cornerRadius: CGFloat?

  public init() {}

  public init(_ properties: [String : Any]) {
    backgroundColor = properties.color("backgroundColor")
    borderColor = properties.color("borderColor")
    borderWidth = properties.cast("borderWidth")
    cornerRadius = properties.cast("cornerRadius")
  }

  public mutating func merge(_ other: StyleProperties) {
    merge(&backgroundColor, other.backgroundColor)
    merge(&borderColor, other.borderColor)
    merge(&borderWidth, other.borderWidth)
    merge(&cornerRadius, other.cornerRadius)
  }
}

public func ==(lhs: StyleProperties, rhs: StyleProperties) -> Bool {
  return lhs.backgroundColor == rhs.backgroundColor && lhs.borderColor == rhs.borderColor && lhs.borderWidth == rhs.borderWidth
}

public struct GestureProperties: RawPropertiesReceiver, Model, Equatable {
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

public protocol ViewProperties: Properties, Equatable {
  var key: String? { get set }
  var layout: LayoutProperties { get set }
  var style: StyleProperties { get set }
  var gestures: GestureProperties { get set }

  mutating func applyProperties(_ properties: [String: Any])
  mutating func mergeProperties(_ properties: Self)
  func equals<T: ViewProperties>(otherViewProperties: T) -> Bool
}

public extension ViewProperties {
  public mutating func applyProperties(_ properties: [String: Any]) {
    key = properties.cast("key")
    id = properties.cast("id")
    if let classNames: String = properties.cast("classNames") {
      self.classNames = classNames.components(separatedBy: " ")
    }
    layout = LayoutProperties(properties)
    style = StyleProperties(properties)
    gestures = GestureProperties(properties)
  }

  public mutating func mergeProperties(_ properties: Self) {
    layout.merge(properties.layout)
    style.merge(properties.style)
    gestures.merge(properties.gestures)
  }

  public func equals<T: ViewProperties>(otherViewProperties: T) -> Bool {
    return key == otherViewProperties.key && layout == otherViewProperties.layout && style == otherViewProperties.style && gestures == otherViewProperties.gestures
  }
}

public struct BaseProperties: ViewProperties {
  public var key: String?
  public var id: String?
  public var classNames: [String]?
  public var layout = LayoutProperties()
  public var style = StyleProperties()
  public var gestures = GestureProperties()

  public init() {}

  public init(_ properties: [String: Any]) {
    applyProperties(properties)
  }

  public mutating func merge(_ other: BaseProperties) {
    mergeProperties(other)
  }
}

public func ==(lhs: BaseProperties, rhs: BaseProperties) -> Bool {
  return lhs.equals(otherViewProperties: rhs)
}
