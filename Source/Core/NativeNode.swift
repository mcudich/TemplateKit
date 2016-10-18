//
//  NativeNode.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/7/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import CSSLayout

class NativeNode<T: NativeView>: PropertyNode {
  weak var parent: Node?
  weak var owner: Node?
  var context: Context?

  var properties: T.PropertiesType
  var children: [Node]? {
    didSet {
      updateParent()
    }
  }
  var element: ElementData<T.PropertiesType>
  var builtView: T?
  var cssNode: CSSNode?

  required init(element: ElementData<T.PropertiesType>, children: [Node]? = nil, owner: Node? = nil, context: Context? = nil) {
    self.element = element
    self.properties = element.properties
    self.children = children
    self.owner = owner
    self.context = context

    updateParent()
  }

  func build() -> View {
    if builtView == nil {
      builtView = T()
    }

    builtView?.eventTarget = owner
    if builtView?.properties != properties {
      builtView?.properties = properties
    }

    if let children = children {
      builtView?.children = children.map { $0.build() } 
    }

    return builtView!
  }

  func getBuiltView<V>() -> V? {
    return builtView as? V
  }
}
