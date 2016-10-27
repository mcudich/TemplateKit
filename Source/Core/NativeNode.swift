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
  var cssNode: CSSNode?

  lazy var view: View = T()

  required init(element: ElementData<T.PropertiesType>, children: [Node]? = nil, owner: Node? = nil, context: Context? = nil) {
    self.element = element
    self.properties = element.properties
    self.children = children
    self.owner = owner
    self.context = context

    updateParent()
  }

  func build() -> View {
    let view = self.view as! T

    view.eventTarget = owner
    if view.properties != properties {
      view.properties = properties
    }

    if let children = children {
      view.children = children.map { $0.build() }
    }

    return view
  }
}
