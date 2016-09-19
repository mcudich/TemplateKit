//
//  Element.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/3/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public protocol ElementRepresentable {
  func make(_ properties: [String: Any], _ children: [Element]?, _ owner: Node?) -> Node
  func equals(_ other: ElementRepresentable) -> Bool
}

public struct Element: PropertyHolder, Keyable, Equatable {
  public let type: ElementRepresentable
  public let children: [Element]?
  public let properties: [String: Any]

  public init(_ type: ElementRepresentable, _ properties: [String: Any] = [:], _ children: [Element]? = nil) {
    self.type = type
    self.properties = properties
    self.children = children
  }

  public func build(with owner: Node?, context: Context? = nil) -> Node {
    let made = type.make(properties, children, owner)

    made.element = self
    made.context = context

    return made
  }
}

public func ==(lhs: Element, rhs: Element) -> Bool {
  return lhs.properties == rhs.properties && lhs.type.equals(rhs.type) && (lhs.children ?? []) == (rhs.children ?? [])
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
