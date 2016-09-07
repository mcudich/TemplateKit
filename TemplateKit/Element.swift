//
//  Element.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/3/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public struct Element: Equatable {
  let type: ElementRepresentable
  let properties: [String: Any]
  let children: [Element]?
  weak var owner: Node?

  public init(_ type: ElementRepresentable, _ properties: [String: Any] = [:], _ children: [Element]? = nil, owner: Node? = nil) {
    self.type = type
    self.properties = properties
    self.children = children
    self.owner = owner
  }

  public func get<T>(_ key: String) -> T? {
    return properties[key] as? T
  }
}

extension Element: CustomStringConvertible {
  public var description: String {
    return description(forDepth: 0)
  }

  private func description(forDepth depth: Int) -> String {
    let depthPadding = (0...depth).reduce("") { accum, _ in accum + " " }
    let childrenDescription = (children?.map { "\(depthPadding)  \($0.description(forDepth: depth + 1))" } ?? []).joined()
    let propertiesDescription = properties.map { entry in " \(entry.key)=\(entry.value)" }.joined()
    return "\(depthPadding)<\(type)\(propertiesDescription)>\n\(childrenDescription)"
  }
}

public func ==(lhs: Element, rhs: Element) -> Bool {
  // TODO(mcudich): Check type equality.
  return lhs.properties == rhs.properties
}
