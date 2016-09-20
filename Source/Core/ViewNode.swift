//
//  OpaqueView.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/8/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public protocol Updateable {
  func update()
}

class ViewNode: PropertyNode {
  weak var owner: Node?
  weak var parent: Node?
  var context: Context?

  var properties: BaseProperties
  var children: [Node]? {
    didSet {
      updateParent()
    }
  }
  var element: Element
  var cssNode: CSSNode?
  var builtView: View?

  required init(element: Element, properties: [String: Any], children: [Node]?, owner: Node?) {
    self.element = element
    self.properties = BaseProperties(properties)
    self.children = children
    self.owner = owner

    updateParent()
  }

  init(view: UIView, element: Element, properties: BaseProperties, owner: Node? = nil) {
    self.element = element
    self.builtView = view
    self.properties = properties
  }

  init(element: Element, properties: BaseProperties, children: [Node]? = nil, owner: Node? = nil) {
    self.element = element
    self.properties = properties
    self.children = children
    self.owner = owner

    updateParent()
  }

  func build<V: View>() -> V {
    if let updateableView = builtView as? Updateable, builtView != nil {
      updateableView.update()
    }
    return builtView as! V
  }
}
