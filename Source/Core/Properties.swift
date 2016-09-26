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
}

public protocol Properties: RawPropertiesReceiver, Model {
  var key: String? { get }

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
  func equals<T: ViewProperties>(otherViewProperties: T) -> Bool
}

public extension ViewProperties {
  public mutating func applyProperties(_ properties: [String: Any]) {
    key = properties.cast("key")
    layout = LayoutProperties(properties)
    style = StyleProperties(properties)
    gestures = GestureProperties(properties)
  }

  public func equals<T: ViewProperties>(otherViewProperties: T) -> Bool {
    return key == otherViewProperties.key && layout == otherViewProperties.layout && style == otherViewProperties.style && gestures == otherViewProperties.gestures
  }
}

public struct BaseProperties: ViewProperties {
  public var key: String?
  public var layout = LayoutProperties()
  public var style = StyleProperties()
  public var gestures = GestureProperties()

  public init() {}

  public init(_ properties: [String: Any]) {
    applyProperties(properties)
  }
}

public func ==(lhs: BaseProperties, rhs: BaseProperties) -> Bool {
  return lhs.equals(otherViewProperties: rhs)
}
