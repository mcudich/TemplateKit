//
//  Properties.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/19/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public protocol Properties: RawProperties, Equatable {
  var core: CoreProperties { get set }

  init()
  func equals<T: Properties>(otherProperties: T) -> Bool
  func has(key: String, withValue value: String) -> Bool
}

public extension Properties {
  public func equals<T: Properties>(otherProperties: T) -> Bool {
    return core == otherProperties.core
  }

  public func has(key: String, withValue value: String) -> Bool {
    return false
  }
}

public protocol FocusableProperties {
  var focused: Bool? { get set }
}

public protocol EnableableProperties {
  var enabled: Bool? { get set }
}

public protocol ActivatableProperties {
  var active: Bool? { get set }
}

public protocol InheritingProperties {
  var textStyle: TextStyleProperties { get set }
}

public protocol InheritableProperties: InheritingProperties {
  func apply(to other: inout InheritingProperties)
}

public extension InheritableProperties {
  func apply(to other: inout InheritingProperties) {
    var workingTextStyle = textStyle

    workingTextStyle.merge(other.textStyle)
    other.textStyle = workingTextStyle
  }
}
