//
//  Renderer.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/8/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public protocol Context {
  var templateService: TemplateService { get }
  var updateQueue: DispatchQueue { get }
}

public protocol Renderer {
  associatedtype ViewType: View
  static func render(_ element: Element, container: ViewType?, context: Context?, completion: @escaping (Component) -> Void)
  static var defaultContext: Context { get }
}

public extension Renderer {
  static func render(_ element: Element, container: ViewType? = nil, context: Context? = nil, completion: @escaping (Component) -> Void) {
    let context = context ?? defaultContext
    let component = element.build(with: nil, context: context) as! Component
    let layout = component.computeLayout()

    DispatchQueue.main.async {
      let builtView: ViewType = component.build()
      builtView.applyLayout(layout: layout)
      if let container = container {
        container.addSubview(builtView)
      }
      completion(component)
    }
  }
}
