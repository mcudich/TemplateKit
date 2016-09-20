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

public protocol State: Equatable {
  init()
}

public protocol Component: PropertyNode, Updateable {
  associatedtype StateType: State
  associatedtype ViewType: View

  var state: StateType { get set }
  var instance: Node { get set }
  var root: Node { get }
  var builtView: ViewType? { get set }

  func render() -> Element
  func shouldUpdate(nextProperties: PropertiesType, nextState: StateType) -> Bool
  func updateState(stateMutation: @escaping (inout StateType) -> Void)
}

public extension Component {
  public var root: Node {
    var current = owner ?? self
    while let currentOwner = current.owner {
      current = currentOwner
    }
    return current
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
    let isNew = builtView == nil

    if isNew {
      willBuild()
    }

    builtView = instance.build() as ViewType

    if isNew {
      didBuild()
    } else {
      didUpdate()
    }

    return builtView as! V
  }

  func update() {
    performUpdate(shouldUpdate: true, nextState: state)
  }

  public func updateState(stateMutation: @escaping (inout StateType) -> Void) {
    willUpdate()
    update(stateMutation: stateMutation)
  }

  func update(stateMutation: @escaping (inout StateType) -> Void) {
    getContext().updateQueue.async {
      let nextProperties = self.properties
      var nextState = self.state
      stateMutation(&nextState)
      let shouldUpdate = self.shouldUpdate(nextProperties: nextProperties, nextState: nextState)

      self.performUpdate(shouldUpdate: shouldUpdate, nextState: nextState)
    }
  }

  func performUpdate(shouldUpdate: Bool, nextState: StateType) {
    self.state = nextState

    if !shouldUpdate {
      return
    }

    let previousInstance = instance
    let previousParentView = builtView?.parent
    let previousView = builtView

    self.update(with: self.element!)
    let layout = self.root.computeLayout()

    DispatchQueue.main.async {
      if previousInstance !== self.instance {
        // We've changed instances in a component that is nested in another. Just ask the parent to
        // rebuild. This will pick up the new instance and rebuild it.
        if let parent = self.parent {
          let _: ViewType = parent.build()
        } else {
          // We don't have a parent because this is a root component. Attempt to silently re-parent the newly built view.
          let view: ViewType = self.build()
          previousParentView!.replace(previousView!, with: view)
        }
      } else {
        // We've modified state, but have not changed the root instance. Flush all node changes to the view layer.
        let _: ViewType = self.build()
      }
      layout.apply(to: self.root.build() as ViewType)
    }
  }

  func shouldUpdate(nextProperties: [String : Any]) -> Bool {
    return shouldUpdate(nextProperties: nextProperties, nextState: state)
  }

  func shouldUpdate(nextProperties: [String : Any], nextState: StateType) -> Bool {
    return true
  }

  func performDiff() {
    let rendered = render()
    // The case where the root node changes type.
    if shouldReplace(instance, with: rendered) {
      instance = rendered.build(with: self, context: context)
      root.cssNode = nil
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
