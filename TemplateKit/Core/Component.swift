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
  var componentState: Any? { get set }
  var context: Context? { get set }

  init(properties: [String: Any], owner: Component?)

  func render() -> Element
  func updateState(stateMutation: (() -> Any?)?)
}

public extension Component {
  public var builtView: View? {
    return instance?.builtView
  }

  public var children: [Node]? {
    get {
      return instance?.children
    }
    set {
      instance?.children = newValue
    }
  }

  public func build() -> View {
    guard let instance = instance else {
      fatalError()
    }

    let isNew = instance.builtView == nil

    if isNew {
      willBuild()
    }

    let newBuild = instance.build()

    if isNew {
      didBuild()
    } else {
      didUpdate()
    }

    return newBuild
  }

  func update() {
    updateState(stateMutation: nil)
  }

  public func updateState(stateMutation: (() -> Any?)?) {
    willUpdate()
    update(stateMutation: stateMutation)
  }

  func update(stateMutation: (() -> Any?)?) {
    DispatchQueue.global(qos: .background).async {
      if let mutation = stateMutation {
        self.componentState = mutation()
      }
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
