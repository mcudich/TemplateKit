//
//  Component.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/9/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public protocol State: Model, Equatable {
  init()
}

// Type-agnostic protocol, so we can dynamically create components as needed.
public protocol ComponentCreation: Node {
  init(element: Element, children: [Node]?, owner: Node?)
}

public protocol Component: PropertyNode, ComponentCreation {
  associatedtype PropertiesType: Properties
  associatedtype StateType: State
  associatedtype ViewType: View

  var state: StateType { get set }
  var properties: PropertiesType { get set }
  var instance: Node { get set }
  var root: Node { get }
  var builtView: ViewType? { get set }

  func render() -> Element
  func shouldUpdate(nextProperties: PropertiesType, nextState: StateType) -> Bool
  func updateState(stateMutation: @escaping (inout StateType) -> Void, completion: (() -> Void)?)
  func performSelector(_ selector: Selector?, with value: Any?, with otherValue: Any?)
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

  func getBuiltView<V>() -> V? {
    return instance.getBuiltView()
  }

  func shouldUpdate(nextProperties: PropertiesType) -> Bool {
    return shouldUpdate(nextProperties: nextProperties, nextState: state)
  }

  func shouldUpdate(nextProperties: PropertiesType, nextState: StateType) -> Bool {
    return true
  }

  func performDiff() {
    willUpdate()

    let rendered = render()

    if shouldReplace(type: instance.type, with: rendered.type) {
      instance = rendered.build(with: self, context: context)
      cssNode = nil
    } else {
      instance.update(with: rendered)
    }
  }

  func performSelector(_ selector: Selector?, with value: Any? = nil, with otherValue: Any? = nil) {
    guard let owner = owner, let selector = selector else { return }
    let _ = (owner as AnyObject).perform(selector, with: value, with: otherValue)
  }

  func forceUpdate() {
    getContext().updateQueue.async {
      self.performUpdate(shouldUpdate: true, nextState: self.state)
    }
  }

  func updateState(stateMutation: @escaping (inout StateType) -> Void, completion: (() -> Void)? = nil) {
    willUpdate()
    update(stateMutation: stateMutation, completion: completion)
  }

  private func update(stateMutation: @escaping (inout StateType) -> Void, completion: (() -> Void)? = nil) {
    getContext().updateQueue.async {
      let nextProperties = self.properties
      var nextState = self.state
      stateMutation(&nextState)
      let shouldUpdate = self.shouldUpdate(nextProperties: nextProperties, nextState: nextState)
      self.performUpdate(shouldUpdate: shouldUpdate, nextState: nextState)
      completion?()
    }
  }

  private func performUpdate(shouldUpdate: Bool, nextState: StateType) {
    state = nextState

    if !shouldUpdate {
      return
    }

    let previousInstance = instance
    let previousParentView = builtView?.parent
    let previousView = builtView

    performUpdate(with: element, nextProperties: properties, shouldUpdate: shouldUpdate)
    let layout = root.computeLayout()

    DispatchQueue.main.async {
      if previousInstance !== self.instance {
        // We've changed instances in a component that is nested in another. Just ask the parent to
        // rebuild. This will pick up the new instance and rebuild it.
        if let parent = self.parent {
          let _: ViewType = parent.build()
        } else if let previousParentView = previousParentView {
          // We don't have a parent because this is a root component. Attempt to silently re-parent the newly built view.
          let view: ViewType = self.build()
          previousParentView.replace(previousView!, with: view)
        }
      } else {
        let _: ViewType = self.build()
      }
      layout.apply(to: self.root.getBuiltView()! as ViewType)
    }
  }
}
