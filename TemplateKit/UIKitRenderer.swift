//
//  UIKitRenderer.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/3/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import SwiftBox

public enum ElementType: ElementRepresentable, Equatable {
  case box
  case text
  case image
  case node(AnyClass)

  public func make(_ properties: [String: Any], _ children: [Element]?, _ owner: Node?) -> BaseNode {
    switch self {
    case .box:
      return NativeNode<Box>(properties: properties, children: children?.map { UIKitRenderer.instantiate($0, owner: owner) }, owner: owner)
    case .text:
      return NativeNode<Text>(properties: properties, owner: owner)
    case .image:
      return NativeNode<Image>(properties: properties, owner: owner)
    case .node(let nodeClass as Node.Type):
      return nodeClass.init(properties: properties, owner: owner)
    default:
      fatalError()
    }
  }

  public func equals(_ other: ElementRepresentable) -> Bool {
    guard let otherType = other as? ElementType else {
      return false
    }
    return self == otherType
  }
}

public func ==(lhs: ElementType, rhs: ElementType) -> Bool {
  switch (lhs, rhs) {
  case (.box, .box), (.text, .text), (.image, .image):
    return true
  case (.node(let lhsClass), .node(let rhsClass)):
    return lhsClass == rhsClass
  default:
    return false
  }
}

public enum UIKitRenderer {
  public static func render(_ element: Element, completion: @escaping (Node, UIView) -> Void) {
    guard let node = instantiate(element, owner: nil) as? Node else {
      fatalError()
    }

    DispatchQueue.main.async {
      let layout = Layout.perform(materialize(node))
      let builtView = node.build() as! UIView
      Layout.apply(layout, to: builtView)
      completion(node, builtView)
    }
  }

  static func instantiate(_ element: Element, owner: Node?) -> BaseNode {
    let made = element.type.make(element.properties, element.children, owner)

    if let node = made as? Node {
      let currentElement = node.render()
      node.currentElement = currentElement
      node.currentInstance = instantiate(currentElement, owner: node)
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
