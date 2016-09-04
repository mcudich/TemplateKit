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
      return Box(children: children?.map { $0.type.make($0.properties, $0.children) } ?? [])
    case .text:
      return Text()
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
    case ElementType.node(let nodeClass):
      if let nodeClass = nodeClass as? Node.Type {
        return resolve(nodeClass.init(properties: element.properties).render())
      }
    default:
      return Element(element.type, element.properties, element.children?.map { resolve($0) })
    }
    fatalError()
  }

  static func layout(_ element: Element) -> SwiftBox.Layout {
    return Layout.perform(element)
  }

  static func make(_ element: Element) -> UIView {
    return element.type.make(element.properties, element.children)
  }
}
