//
//  UIKitRenderer.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/3/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import SwiftBox

public enum ElementType: ElementRepresentable {
  case box
  case text
  case image
  case node(AnyClass)

  public func make(_ properties: [String: Any], _ children: [Element]?) -> BaseNode {
    switch self {
    case .box:
      return NativeNode<Box>(properties: properties, children: children?.map { UIKitRenderer.instantiate($0) })
    case .text:
      return NativeNode<Text>(properties: properties)
    case .image:
      return NativeNode<Image>(properties: properties)
    case .node(let nodeClass as Node.Type):
      return nodeClass.init(properties: properties)
    default:
      fatalError()
    }
  }

  public var hashValue: Int {
    switch self {
    case .box:
      return 0
    case .text:
      return 1
    case .image:
      return 2
    case .node(let nodeClass as Node.Type):
      return "\(type(of: nodeClass))".hashValue
    default:
      fatalError()
    }
  }
}

public func ==(lhs: ElementType, rhs: ElementType) -> Bool {
  return lhs.hashValue == rhs.hashValue
}

public func !=(lhs: ElementType, rhs: ElementType) -> Bool {
  return lhs.hashValue != rhs.hashValue
}

public enum UIKitRenderer {
  public static func render(_ element: Element, completion: @escaping (Node, UIView) -> Void) {
    guard let node = instantiate(element) as? Node else {
      fatalError()
    }

    DispatchQueue.main.async {
      let layout = Layout.perform(materialize(node))
      let builtView = node.build() as! UIView
      Layout.apply(layout, to: builtView)
      completion(node, builtView)
    }
  }

  static func instantiate(_ element: Element) -> BaseNode {
    let made = element.type.make(element.properties, element.children)

    if let node = made as? Node {
      let currentElement = node.render()
      node.currentElement = currentElement
      node.currentInstance = instantiate(currentElement)
    } else {
      made.currentElement = element
    }

    return made
  }

  static func materialize(_ node: Node) -> Element {
    guard let currentInstance = node.currentInstance, let currentElement = currentInstance.currentElement else {
      fatalError()
    }
    let children = currentInstance.children?.map { $0.currentElement! }
    return Element(currentElement.type, currentElement.properties, children)
  }
}
