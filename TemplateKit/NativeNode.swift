//
//  NativeNode.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/7/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

class NativeNode<T: NativeView>: BaseNode {
  var properties: [String: Any]
  var children: [BaseNode]?
  var currentElement: Element?

  private lazy var builtView: T = {
    return T()
  }()

  init(properties: [String: Any], children: [BaseNode]? = nil) {
    self.properties = properties
    self.children = children
  }

  func build() -> NativeView {
    builtView.properties = properties
    let newChildren = children?.map { $0.build() }
    builtView.children = newChildren
    return builtView
  }

  public func get<T>(_ key: String) -> T? {
    return properties[key] as? T
  }
}
