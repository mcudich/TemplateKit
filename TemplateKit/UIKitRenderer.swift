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

  public func make(_ properties: [String: Any], _ children: [Element]?) -> UIView {
    switch self {
    case .box:
      return Box(properties: properties, children: children?.map { UIKitRenderer.make($0) } ?? [])
    case .text:
      return Text(properties: properties)
    case .image:
      return Image()
    default:
      fatalError()
    }
  }
}

public enum UIKitRenderer {
  public static func render(_ element: Element, completion: @escaping (UIView) -> Void) {
    let elementTree = resolve(element)
    let computedLayout = layout(elementTree)
    DispatchQueue.main.async {
      let viewTree = make(elementTree)
      Layout.apply(computedLayout, to: viewTree)
      completion(viewTree)
    }
  }

  static func resolve(_ element: Element) -> Element {
    switch element.type {
    case ElementType.node(let nodeClass as Node.Type):
      let node = nodeClass.init(properties: element.properties)
      var element = resolve(node.render())
      node.currentElement = element
      element.owner = node
      return element
    default:
      return Element(element.type, element.properties, element.children?.map { resolve($0) })
    }
  }

  static func layout(_ element: Element) -> SwiftBox.Layout {
    return Layout.perform(element)
  }

  static func make(_ element: Element) -> UIView {
    let renderedView = element.type.make(element.properties, element.children)
    element.owner?.renderedView = renderedView
    return renderedView
  }
}
