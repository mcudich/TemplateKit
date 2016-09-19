//
//  NativeNode.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/7/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

class NativeNode<T: NativeView>: Node {
  weak var parent: Node?
  weak var owner: Node?
  var context: Context?

  var properties: [String: Any]
  var children: [Node]? {
    didSet {
      updateParent()
    }
  }
  var element: Element?
  var builtView: View?
  var cssNode: CSSNode?

  init(properties: [String: Any], children: [Node]? = nil, owner: Node? = nil) {
    self.properties = properties
    self.children = children
    self.owner = owner

    updateParent()
  }

  func build<V: View>() -> V {
    if builtView == nil {
      builtView = T()
    }

    var view = builtView as! NativeView

    view.eventTarget = owner
    view.properties = properties
    view.children = children?.map { $0.build() as V }

    return view as! V
  }
}
