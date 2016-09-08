//
//  Element.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/3/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public struct Element {
  let type: ElementRepresentable
  let properties: [String: Any]
  let children: [Element]?

  public init(_ type: ElementRepresentable, _ properties: [String: Any] = [:], _ children: [Element]? = nil) {
    self.type = type
    self.properties = properties
    self.children = children
  }

  public func get<T>(_ key: String) -> T? {
    return properties[key] as? T
  }

  public func build(with owner: Node? = nil) -> BaseNode {
    let made = type.make(properties, children, owner)

    if let node = made as? Node {
      let currentElement = node.render()
      node.currentElement = currentElement
      node.currentInstance = currentElement.build(with: node)
    } else {
      made.currentElement = self
    }

    return made
  }
}

extension Element {
  public var recursiveDescription: String {
    return description(forDepth: 0)
  }

  private func description(forDepth depth: Int) -> String {
    let depthPadding = (0...depth).reduce("") { accum, _ in accum + " " }
    let childrenDescription = (children?.map { "\(depthPadding)  \($0.description(forDepth: depth + 1))" } ?? []).joined()
    let propertiesDescription = properties.map { entry in " \(entry.key)=\(entry.value)" }.joined()
    return "\(depthPadding)<\(type)\(propertiesDescription)>\n\(childrenDescription)"
  }
}
