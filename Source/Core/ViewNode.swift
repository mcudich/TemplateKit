//
//  OpaqueView.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/8/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

class ViewNode: Node {
  weak var owner: Component?
  var properties = [String: Any]()
  var children: [Node]?
  var element: Element?
  var cssNode: CSSNode?
  var builtView: View?

  init(view: UIView) {
    self.builtView = view
  }

  init(properties: [String: Any], children: [Node]? = nil, owner: Component? = nil) {
    self.properties = properties
    self.children = children
    self.owner = owner
  }

  func build() -> View {
    if let updateableView = builtView as? Updateable, builtView != nil {
      updateableView.update()
    }
    return builtView!
  }
}
