//
//  Element.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/3/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public protocol ElementRepresentable {
  func make(_ element: Element, _ owner: Node?) -> Node
  func equals(_ other: ElementRepresentable) -> Bool
}

public protocol Element: Keyable {
  var type: ElementRepresentable { get }
  var children: [Element]? { get }

  func build(with owner: Node?, context: Context?) -> Node
}

public struct ElementData<PropertiesType: Properties>: Element {
  public let type: ElementRepresentable
  public let children: [Element]?
  public let properties: PropertiesType

  public var key: String? {
    return properties.key
  }

  public init(_ type: ElementRepresentable, _ properties: PropertiesType, _ children: [Element]? = nil) {
    self.type = type
    self.properties = properties
    self.children = children
  }

  public func build(with owner: Node?, context: Context? = nil) -> Node {
    let made = type.make(self, owner)

    made.context = context

    return made
  }
}
