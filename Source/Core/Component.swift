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

public protocol State {
  init()
  func equals(other: State) -> Bool
}

public extension State where Self: Equatable {
  func equals(other: State) -> Bool {
    guard let other = other as? Self else {
      return false
    }
    return self == other
  }
}

public protocol Component: Node, Updateable {
  var componentState: State { get set }
  var instance: Node { get set}

  init(properties: [String: Any], owner: Node?)

  func render() -> Element
  func shouldUpdate(nextProperties: [String: Any], nextState: State) -> Bool
  func updateState<T: State>(stateMutation: @escaping (inout T) -> Void)
}

public extension Component {
  public var builtView: View? {
    return instance.builtView
  }

  public var cssNode: CSSNode? {
    set {
      instance.cssNode = newValue
    }
    get {
      return instance.cssNode
    }
  }

  public var children: [Node]? {
    set {
      instance.children = newValue
    }
    get {
      return instance.children
    }
  }

  public func build<V: View>() -> V {
    let isNew = instance.builtView == nil

    if isNew {
      willBuild()
    }

    let newBuild: V = instance.build()

    if isNew {
      didBuild()
    } else {
      didUpdate()
    }

    return newBuild
  }

  func update() {
    performUpdate(shouldUpdate: true, nextState: componentState)
  }

  public func updateState<T: State>(stateMutation: @escaping (inout T) -> Void) {
    willUpdate()
    update(stateMutation: stateMutation)
  }

  func update<T: State>(stateMutation: @escaping (inout T) -> Void) {
    getContext().updateQueue.async {
      let nextProperties = self.properties
      var nextState = self.componentState as! T
      stateMutation(&nextState)
      let shouldUpdate = self.shouldUpdate(nextProperties: nextProperties, nextState: nextState)

      self.performUpdate(shouldUpdate: shouldUpdate, nextState: nextState)
    }
  }

  func performUpdate(shouldUpdate: Bool, nextState: State) {
    self.componentState = nextState

    if !shouldUpdate {
      return
    }

    let previousInstance = instance
    let previousParentView = instance.builtView?.superview
    let previousView = instance.builtView

    self.update(with: self.element!)
    let layout = self.computeLayout()

    DispatchQueue.main.async {
      if previousInstance !== self.instance {
        // We've changed instances in a component that is nested in another. Just ask the parent to
        // rebuild. This will pick up the new instance and rebuild it.
        if let parent = self.parent {
          let _: UIView = parent.build()
        } else {
          // We don't have a parent because this is a root component. Attempt to silently re-parent the newly built view.
          let view: UIView = self.build()
          previousParentView!.replace(previousView!, with: view)
        }
      } else {
        // We've modified state, but have not changed the root instance. Flush all node changes to the view layer.
        let _: UIView = self.build()
      }
      self.root?.builtView?.applyLayout(layout: layout)
    }
  }

  func shouldUpdate(nextProperties: [String : Any]) -> Bool {
    return shouldUpdate(nextProperties: nextProperties, nextState: componentState)
  }

  func shouldUpdate(nextProperties: [String : Any], nextState: State) -> Bool {
    return true
  }

  func performDiff() {
    let rendered = render()
    // The case where the root node changes type.
    if shouldReplace(instance, with: rendered) {
      instance = rendered.build(with: self, context: context)
      root?.cssNode = nil
    } else {
      instance.update(with: rendered)
    }
  }

  func getContext() -> Context {
    guard let context = context ?? owner?.context else {
      fatalError("No context available")
    }
    return context
  }
}
