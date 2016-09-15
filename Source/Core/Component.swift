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
  func shouldUpdate(nextProperties: [String: Any], nextState: Any) -> Bool
  func updateState(stateMutation: (() -> Any?)?)
}

public extension Component {
  public var builtView: View? {
    return instance?.builtView
  }

  public var cssNode: CSSNode? {
    set {
      instance?.cssNode = newValue
    }
    get {
      return instance?.cssNode
    }
  }

  public var children: [Node]? {
    set {
      instance?.children = newValue
    }
    get {
      return instance?.children
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
    getContext().updateQueue.async {
      let nextProperties = self.element!.properties
      let nextState = stateMutation?()
      if self.shouldUpdate(nextProperties: nextProperties, nextState: nextState) {
        if let nextState = nextState {
          self.componentState = nextState
        }
        self.update(with: self.element!)
      } else {
        self.componentState = nextState
        return
      }

      let layout = self.computeLayout()

      DispatchQueue.main.async {
        let _ = self.build()
        self.root?.builtView?.applyLayout(layout: layout)
      }
    }
  }

  func shouldUpdate(nextProperties: [String : Any]) -> Bool {
    return shouldUpdate(nextProperties: nextProperties, nextState: componentState)
  }

  func shouldUpdate(nextProperties: [String : Any], nextState: Any) -> Bool {
    return properties != nextProperties
  }

  func performDiff() {
    instance?.update(with: render())
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
