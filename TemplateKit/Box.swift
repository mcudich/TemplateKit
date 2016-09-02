//
//  Box.swift
//  TemplateKit
//
//  Created by Matias Cudich on 8/31/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import SwiftBox

public class Box: ContainerNode {
  public typealias View = UIView

  public var root: Node?
  public var renderedView: UIView?
  public let properties: [String: Any]
  public var state: Any?
  public var calculatedFrame: CGRect?
  public var eventTarget = EventTarget()

  public var children: [Node]

  public var padding: Edges {
    return Edges(left: get("paddingLeft") ?? 0, right: get("paddingRight") ?? 0, bottom: get("paddingBottom") ?? 0, top: get("paddingTop") ?? 0)
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

  public required init(properties: [String : Any]) {
    self.properties = properties
    self.children = []
  }

  public required init(properties: [String : Any], children: () -> [Node]) {
    self.properties = properties
    self.children = children()
  }

  public func sizeThatFits(_ size: CGSize) -> CGSize {
    let layout = flexNode.layout(withMaxWidth: size.width)

    apply(layout: layout)

    return layout.frame.size
  }

  private func apply(layout: Layout) {
    for (index, layout) in layout.children.enumerated() {
      let child = children[index]
      child.calculatedFrame = layout.frame
      if let box = child as? Box {
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
    return Edges(left: get("marginLeft") ?? 0, right: get("marginRight") ?? 0, bottom: get("marginBottom") ?? 0, top: get("marginTop") ?? 0)
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
    let flexNodes = children.map { $0.build().flexNode }

    return FlexNode(size: flexSize, children: flexNodes, direction: flexDirection, margin: margin, padding: padding, wrap: false, justification: justification, selfAlignment: selfAlignment, childAlignment: childAlignment, flex: flex)
  }
}
