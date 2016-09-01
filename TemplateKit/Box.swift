//
//  Box.swift
//  TemplateKit
//
//  Created by Matias Cudich on 8/31/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import SwiftBox

public struct Box: ContainerNode {
  public let properties: [String: Any]
  public var calculatedFrame: CGRect?

  public var children: [Node]

  public var padding: Edges {
    return get("padding") ?? Edges()
  }
  public var flexDirection: Direction {
    return get("flexDirection") ?? .column
  }
  public var justification: Justification {
    return get("justification") ?? .flexStart
  }
  public var childAlignment: ChildAlignment {
    return get("childAlignment") ?? .stretch
  }

  public init(properties: [String : Any]) {
    self.properties = properties
    self.children = []
  }

  public init(properties: [String : Any], children: () -> [Node]) {
    self.init(properties: properties)
    self.children = children()
  }

  public func build(completion: (Node) -> Void) {
    completion(self)
  }

  public mutating func sizeThatFits(_ size: CGSize, completion: (CGSize) -> Void) {
    let layout = flexNode.layout(withMaxWidth: size.width)

    apply(layout: layout)

    completion(layout.frame.size)
  }

  private mutating func apply(layout: Layout) {
    for (index, layout) in layout.children.enumerated() {
      children[index].calculatedFrame = layout.frame
      if var box = children[index] as? Box {
        box.apply(layout: layout)
      }
    }
  }
}

public typealias FlexNode = SwiftBox.Node

public protocol Layoutable {
  var flexNode: FlexNode { get }
  var flexSize: CGSize { get }
  var margin: Edges { get }
  var selfAlignment: SelfAlignment { get }
  var flex: CGFloat { get }
}

public extension Layoutable where Self: Node {
  var flexNode: FlexNode {
    return FlexNode(size: flexSize, margin: margin, selfAlignment: selfAlignment, flex: flex)
  }

  public var flexSize: CGSize {
    let width: CGFloat = get("width") ?? FlexNode.Undefined
    let height: CGFloat = get("height") ?? FlexNode.Undefined

    return CGSize(width: width, height: height)
  }
  public var margin: Edges {
    return get("margin") ?? Edges()
  }
  public var selfAlignment: SelfAlignment {
    return get("selfAlignment") ?? .auto
  }
  public var flex: CGFloat {
    return get("flex") ?? 0
  }
}

extension Box: Layoutable {
  public var flexNode: FlexNode {
    let flexNodes = children.map { $0.flexNode }

    return FlexNode(size: flexSize, children: flexNodes, direction: flexDirection, margin: margin, padding: padding, wrap: false, justification: justification, selfAlignment: selfAlignment, childAlignment: childAlignment, flex: flex)
  }
}
