//
//  StyleSheet+Element.swift
//  TemplateKit
//
//  Created by Matias Cudich on 10/26/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import CSSParser

public extension StyleElement where Self: Element {
  var parentElement: StyleElement? {
    return parent
  }

  var childElements: [StyleElement]? {
    return children
  }
}

extension ElementData: StyleElement {
  public var id: String? {
    return properties.core.identifier.id
  }

  public var classNames: [String]? {
    return properties.core.identifier.classNames
  }

  public var tagName: String? {
    return type.tagName
  }

  public var isFocused: Bool {
    if let focusable = properties as? FocusableProperties {
      return focusable.focused ?? false
    }
    return false
  }

  public var isEnabled: Bool {
    if let enableable = properties as? EnableableProperties {
      return enableable.enabled ?? false
    }
    return false
  }

  public var isActive: Bool {
    if let activatable = properties as? ActivatableProperties {
      return activatable.active ?? false
    }
    return false
  }

  public func has(attribute: String, with value: String) -> Bool {
    return properties.has(key: attribute, withValue: value)
  }

  public func equals(_ other: StyleElement) -> Bool {
    return equals(other as? Element)
  }

  public func apply(styles: [String : Any]) {
    var styledProperties = PropertiesType(styles)
    styledProperties.merge(properties)
    properties = styledProperties
  }
}
