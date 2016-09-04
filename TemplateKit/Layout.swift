//
//  Layout.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/4/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import SwiftBox

enum Layout {
  static func perform(_ element: Element) -> SwiftBox.Layout {
    return element.node.layout()
  }

  static func apply(_ layout: SwiftBox.Layout, to view: UIView) {
    layout.apply(toView: view)
  }
}

extension Element {
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
  public var flexSize: CGSize {
    let width: CGFloat = get("width") ?? SwiftBox.Node.Undefined
    let height: CGFloat = get("height") ?? SwiftBox.Node.Undefined

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

  var node: SwiftBox.Node {
    switch self.type {
    case ElementType.box:
      let childNodes = children?.map { $0.node } ?? []
      return SwiftBox.Node(size: flexSize, children: childNodes, direction: flexDirection, margin: margin, padding: padding, wrap: false, justification: justification, selfAlignment: selfAlignment, childAlignment: childAlignment, flex: flex)
    case ElementType.text:
      let measure: ((CGFloat) -> CGSize) = { width in
        let _ = width.isNaN ? CGFloat.greatestFiniteMagnitude : width
        return CGSize.zero
      }
      return SwiftBox.Node(size: flexSize, margin: margin, selfAlignment: selfAlignment, flex: flex, measure: measure)
    default:
      return SwiftBox.Node(size: flexSize, margin: margin, selfAlignment: selfAlignment, flex: flex)
    }
  }
}
