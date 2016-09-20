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

public protocol Properties: RawPropertiesReceiver, Equatable {
  var key: String? { get }
}

public struct StyleProperties: RawPropertiesReceiver, Equatable {
  public var backgroundColor: UIColor?

  public init(_ properties: [String : Any]) {
    backgroundColor = properties.get("backgroundColor")
  }
}

public func ==(lhs: StyleProperties, rhs: StyleProperties) -> Bool {
  return lhs.backgroundColor == rhs.backgroundColor
}

public struct GestureProperties: RawPropertiesReceiver, Equatable {
  var onTap: Selector?

  public init(_ properties: [String : Any]) {
    onTap = properties.get("onTap")
  }
}

public func ==(lhs: GestureProperties, rhs: GestureProperties) -> Bool {
  return lhs.onTap == rhs.onTap
}

public protocol ViewProperties: Properties {
  var key: String? { get }
  var layout: LayoutProperties? { get }
  var style: StyleProperties? { get }
  var gestures: GestureProperties? { get }

  func equals<T: ViewProperties>(otherViewProperties: T) -> Bool
}

public extension ViewProperties {
  public func equals<T: ViewProperties>(otherViewProperties: T) -> Bool {
    return key == otherViewProperties.key && layout == otherViewProperties.layout && style == otherViewProperties.style && gestures == otherViewProperties.gestures
  }
}

public struct BaseProperties: ViewProperties {
  public var key: String?
  public var layout: LayoutProperties?
  public var style: StyleProperties?
  public var gestures: GestureProperties?

  public init(_ properties: [String: Any]) {
    key = properties.get("key")
    layout = LayoutProperties(properties)
    style = StyleProperties(properties)
    gestures = GestureProperties(properties)
  }
}

public func ==(lhs: BaseProperties, rhs: BaseProperties) -> Bool {
  return lhs.equals(otherViewProperties: rhs)
}
