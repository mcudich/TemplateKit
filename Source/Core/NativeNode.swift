//
//  NativeNode.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/7/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

class NativeNode<T: NativeView>: Node {
  weak var owner: Component?
  var properties: [String: Any]
  var children: [Node]?
  var element: Element?
  var builtView: View?
  var cssNode: CSSNode

  init(properties: [String: Any], children: [Node]? = nil, owner: Component? = nil) {
    self.properties = properties
    self.children = children
    self.owner = owner
  }

  func build() -> View {
    if builtView == nil {
      builtView = T()
    }

    guard var builtView = builtView as? NativeView else {
      fatalError("Failed to build view")
    }

    builtView.eventTarget = owner
    builtView.properties = properties
    builtView.children = children?.map { $0.build() }

    return builtView
  }
}
