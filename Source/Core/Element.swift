//
//  Element.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/3/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public protocol ElementRepresentable {
  var tagName: String { get }
  func make(_ element: Element, _ owner: Node?) -> Node
  func equals(_ other: ElementRepresentable) -> Bool
}

public protocol Element: Keyable, StyleElement {
  var type: ElementRepresentable { get }
  var children: [Element]? { get }
  var parent: Element? { get set }

  func build(with owner: Node?, context: Context?) -> Node
  mutating func applyStyleSheet(_ styleSheet: StyleSheet?)
}

public extension StyleElement where Self: Element {
  var parentElement: StyleElement? {
    return parent
  }

  var childElements: [StyleElement]? {
    return children
  }
}

public struct ElementData<PropertiesType: Properties>: Element {
  public let type: ElementRepresentable
  public private(set) var children: [Element]?
  public var parent: Element?
  public var properties: PropertiesType

  public var id: String? {
    return properties.id
  }

  public var classNames: [String]? {
    return properties.classNames
  }

  public var tagName: String? {
    return type.tagName
  }

  public var key: String? {
    return properties.key
  }

  public init(_ type: ElementRepresentable, _ properties: PropertiesType, _ children: [Element]? = nil) {
    self.type = type
    self.properties = properties
    self.children = children

    for (index, _) in (self.children ?? []).enumerated() {
      self.children?[index].parent = self
    }
  }

  public func build(with owner: Node?, context: Context? = nil) -> Node {
    let made = type.make(self, owner)

    made.context = context

    return made
  }

  public mutating func applyStyleSheet(_ styleSheet: StyleSheet?) {
    let matchingStyles = styleSheet?.stylesForElement(self)
    var properties = [String: Any]()
    for (name, declaration) in (matchingStyles ?? [:]) {
      properties[name] = declaration.values[0]
    }
    self.properties.merge(properties)

    for (index, _) in (children ?? []).enumerated() {
      children?[index].applyStyleSheet(styleSheet)
    }
  }
}
