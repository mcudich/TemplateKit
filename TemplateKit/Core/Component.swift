//
//  Component.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/9/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public protocol Updateable {
  func update()
}

public protocol Component: Node, Updateable {
  var state: Any? { get set }
  var context: Context? { get set }

  init(properties: [String: Any], owner: Component?)

  func render() -> Element
  func updateState(stateMutation: () -> Any?)
}

public extension Component {
  public func updateState(stateMutation: () -> Any?) {
    state = stateMutation()
    update()
  }

  public var builtView: View? {
    return currentInstance?.builtView
  }

  public var children: [Node]? {
    get {
      return currentInstance?.children
    }
    set {
      currentInstance?.children = newValue
    }
  }

  public func build() -> View {
    guard let currentInstance = currentInstance else {
      fatalError()
    }

    return currentInstance.build()
  }

  func update() {
    DispatchQueue.global(qos: .background).async {
      self.performDiff(newElement: self.render())
      let layout = self.computeLayout()

      DispatchQueue.main.async {
        let _ = self.build()
        self.root?.builtView?.applyLayout(layout: layout)
      }
    }
  }

  func getContext() -> Context {
    if let context = context {
      return context
    }
    if let owner = owner {
      return owner.getContext()
    }
    fatalError("No context available")
  }
}
