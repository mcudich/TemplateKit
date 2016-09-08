//
//  NativeNode.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/7/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

class NativeNode<T: NativeView>: BaseNode {
  weak var owner: Node?
  var properties: [String: Any]
  var children: [BaseNode]?
  var currentElement: Element?

  lazy var builtView: NativeView? = T()

  init(properties: [String: Any], children: [BaseNode]? = nil, owner: Node? = nil) {
    self.properties = properties
    self.children = children
    self.owner = owner
  }

  func build() -> NativeView {
    guard var builtView = builtView else {
      fatalError("Failed to build view")
    }

    builtView.eventTarget = owner
    builtView.properties = properties
    builtView.children = children?.map { $0.build() }

    return builtView
  }

  public func get<T>(_ key: String) -> T? {
    return properties[key] as? T
  }
}
