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
  static func render(_ element: Element, container: ViewType?, context: Context?, completion: @escaping (Node) -> Void)
  static var defaultContext: Context { get }
}

public extension Renderer {
  static func render(_ element: Element, container: ViewType? = nil, context: Context? = nil, completion: @escaping (Node) -> Void) {
    let context = context ?? defaultContext
    context.updateQueue.async {
      let component = element.build(withOwner: nil, context: context)
      let layout = component.computeLayout()

      DispatchQueue.main.async {
        let builtView: ViewType = component.build()
        layout.apply(to: builtView)
        container?.add(builtView)
        completion(component)
      }
    }
  }
}
