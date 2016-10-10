//
//  CompositeComponent.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/11/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public protocol State: Model, Equatable {
  init()
}

// Type-agnostic protocol, so we can dynamically create components as needed.
public protocol ComponentCreation: Node {
  init(element: Element, children: [Node]?, owner: Node?, context: Context?)
}

public struct EmptyState: State {
  public init() {}
}

public func ==(lhs: EmptyState, rhs: EmptyState) -> Bool {
  return true
}

open class Component<StateType: State, PropertiesType: Properties, ViewType: View>: PropertyNode, Model, ComponentCreation {
  public weak var parent: Node?
  public weak var owner: Node?

  public var element: ElementData<PropertiesType>
  public var builtView: ViewType?
  public var context: Context?
  public lazy var state: StateType = {
    return self.getInitialState()
  }()

  open var properties: PropertiesType

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

  var instance: Node!

  public required init(element: Element, children: [Node]? = nil, owner: Node? = nil, context: Context? = nil) {
    self.element = element as! ElementData<PropertiesType>
    self.properties = self.element.properties
    self.owner = owner
    self.context = context

    instance = renderElement().build(with: self, context: nil)
  }

  public func render(_ location: URL) -> Template {
    getContext().templateService.addObserver(observer: self, forLocation: location)

    return getContext().templateService.templates[location]!
  }

  public func updateComponentState(stateMutation: @escaping (inout StateType) -> Void) {
    updateState(stateMutation: { (state: inout StateType) in
      stateMutation(&state)
    })
  }

  public func updateComponentState(stateMutation: @escaping (inout StateType) -> Void, completion: (() -> Void)?) {
    updateState(stateMutation: { (state: inout StateType) in
      stateMutation(&state)
    }, completion: completion)
  }

  public func build<V: View>() -> V {
    let isNew = builtView == nil

    builtView = instance.build() as ViewType

    if isNew {
      didBuild()
    } else {
      didUpdate()
    }

    return builtView as! V
  }

  public func getBuiltView<V>() -> V? {
    return instance.getBuiltView()
  }

  public func shouldUpdate(nextProperties: PropertiesType) -> Bool {
    return shouldUpdate(nextProperties: nextProperties, nextState: state)
  }

  public func performDiff() {
    let rendered = renderElement()

    if shouldReplace(type: instance.type, with: rendered.type) {
      instance = rendered.build(with: self, context: context)
      cssNode = nil
    } else {
      instance.update(with: rendered)
    }
  }

  public func performSelector(_ selector: Selector?, with value: Any? = nil, with otherValue: Any? = nil) {
    guard let owner = owner, let selector = selector else { return }
    let _ = (owner as AnyObject).perform(selector, with: value, with: otherValue)
  }

  public func forceUpdate() {
    getContext().updateQueue.async {
      self.performUpdate(shouldUpdate: true, nextState: self.state)
    }
  }

  private func updateState(stateMutation: @escaping (inout StateType) -> Void, completion: (() -> Void)? = nil) {
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
    if shouldUpdate {
      willUpdate()
    }

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

  private func renderElement() -> Element {
    return render().build(with: self)
  }

  open func render() -> Template {
    fatalError("Must be implemented by subclasses")
  }

  open func shouldUpdate(nextProperties: PropertiesType, nextState: StateType) -> Bool {
    return properties != nextProperties || state != nextState
  }

  open func getInitialState() -> StateType {
    return StateType()
  }

  open func willBuild() {}
  open func didBuild() {}
  open func willUpdate() {}
  open func didUpdate() {}
  open func willDetach() {}
}
