//
//  Element.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/3/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import CSSParser

public protocol ElementRepresentable {
  var tagName: String { get }
  func make(_ element: Element, _ owner: Node?, _ context: Context?) -> Node
  func equals(_ other: ElementRepresentable) -> Bool
}

public protocol Element: class, Keyable, StyleElement, ElementProvider {
  var type: ElementRepresentable { get }
  var children: [Element]? { get }
  weak var parent: Element? { get set }

  func build(withOwner owner: Node?, context: Context?) -> Node
}

extension ElementProvider where Self: Element {
  public func build(with model: Model) -> Element {
    return self
  }
}

public class ElementData<PropertiesType: Properties>: Element {
  public let type: ElementRepresentable
  public private(set) var children: [Element]?
  public weak var parent: Element?
  public var properties: PropertiesType

  public var key: String? {
    get {
      return properties.core.identifier.key
    }
    set {
      properties.core.identifier.key = newValue
    }
  }

  public init(_ type: ElementRepresentable, _ properties: PropertiesType, _ children: [Element]? = nil) {
    self.type = type
    self.properties = properties
    self.children = children

    for (index, child) in (self.children ?? []).enumerated() {
      self.children?[index].parent = self
      self.children?[index].key = child.key ?? "\(index)"
    }
  }

  public func build(withOwner owner: Node?, context: Context? = nil) -> Node {
    return type.make(self, owner, context)
  }

  public func equals(_ other: Element?) -> Bool {
    guard let other = other as? ElementData<PropertiesType> else {
      return false
    }

    return type.equals(other.type) && key == other.key && (parent?.equals(other.parent) ?? (other.parent == nil)) && properties == other.properties
  }

  public func equals(_ other: ElementProvider?) -> Bool {
    return equals(other as? Element)
  }
}
