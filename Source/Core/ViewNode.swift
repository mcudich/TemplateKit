//
//  OpaqueView.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/8/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import CSSLayout

class ViewNode<ViewType: View>: PropertyNode {
  weak var owner: Node?
  weak var parent: Node?
  var context: Context?

  var properties: DefaultProperties
  var children: [Node]?
  var element: ElementData<DefaultProperties>
  var cssNode: CSSNode?
  var builtView: ViewType?

  init(view: ViewType, element: ElementData<DefaultProperties>, owner: Node? = nil, context: Context? = nil) {
    self.builtView = view
    self.element = element
    self.properties = self.element.properties
    self.owner = owner
    self.context = context
  }

  func build() -> View {
    return builtView!
  }

  func getBuiltView<V>() -> V? {
    return builtView as? V
  }
}
