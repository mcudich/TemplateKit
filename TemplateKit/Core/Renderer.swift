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
  static func render(_ element: Element, completion: @escaping (Component, ViewType) -> Void)
}

public extension Renderer {
  static func render(_ element: Element, completion: @escaping (Component, ViewType) -> Void) {
    guard let component = element.build() as? Component else {
      fatalError()
    }

    let layout = component.computeLayout()

    DispatchQueue.main.async {
      guard let builtView = component.build() as? ViewType else {
        fatalError("Unexpected view type")
      }
      builtView.applyLayout(layout: layout)
      completion(component, builtView)
    }
  }
}
