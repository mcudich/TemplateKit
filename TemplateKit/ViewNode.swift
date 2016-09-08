//
//  OpaqueView.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/8/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

class ViewNode: BaseNode {
  weak var owner: Node?
  var properties = [String: Any]()
  var children: [BaseNode]?
  var currentElement: Element?

  var builtView: View?

  init(view: UIView) {
    self.builtView = view
  }

  init(properties: [String: Any], children: [BaseNode]? = nil, owner: Node? = nil) {
    self.properties = properties
    self.children = children
    self.owner = owner
  }

  func build() -> View {
    return builtView!
  }
}
