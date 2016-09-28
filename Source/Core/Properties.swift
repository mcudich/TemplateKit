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

public struct IdentifierProperties: RawPropertiesReceiver, Model, Equatable {
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

public protocol Properties: RawPropertiesReceiver, Model {
  var identifier: IdentifierProperties { get set }

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
  var layout: LayoutProperties { get set }
  var style: StyleProperties { get set }
  var gestures: GestureProperties { get set }

  mutating func applyProperties(_ properties: [String: Any])
  mutating func mergeProperties(_ properties: Self)
  func equals<T: ViewProperties>(otherViewProperties: T) -> Bool
}

public extension ViewProperties {
  public mutating func applyProperties(_ properties: [String: Any]) {
    identifier = IdentifierProperties(properties)
    layout = LayoutProperties(properties)
    style = StyleProperties(properties)
    gestures = GestureProperties(properties)
  }

  public mutating func mergeProperties(_ properties: Self) {
    identifier.merge(properties.identifier)
    layout.merge(properties.layout)
    style.merge(properties.style)
    gestures.merge(properties.gestures)
  }

  public func equals<T: ViewProperties>(otherViewProperties: T) -> Bool {
    return identifier == otherViewProperties.identifier && layout == otherViewProperties.layout && style == otherViewProperties.style && gestures == otherViewProperties.gestures
  }
}

public struct BaseProperties: ViewProperties {
  public var identifier = IdentifierProperties()
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
