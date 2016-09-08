//
//  Renderer.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/8/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public protocol Renderer {
  associatedtype ViewType: Layoutable
  static func render(_ element: Element, completion: @escaping (Node, ViewType) -> Void)
}

public extension Renderer {
  static func render(_ element: Element, completion: @escaping (Node, ViewType) -> Void) {
    guard let node = element.build() as? Node else {
      fatalError()
    }

    let layout = node.computeLayout()

    DispatchQueue.main.async {
      guard let builtView = node.build() as? ViewType else {
        fatalError("Unexpected view type")
      }
      builtView.applyLayout(layout: layout)
      completion(node, builtView)
    }
  }
}
