//
//  CompositeComponent.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/11/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import CSSLayout

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
  public typealias StateMutation = (inout StateType) -> Void
  public typealias StateMutationCallback = () -> Void

  public weak var parent: Node?
  public weak var owner: Node?

  public var element: ElementData<PropertiesType>
  public var builtView: ViewType?
  public var context: Context?
  public lazy var state: StateType = self.getInitialState()

  public var properties: PropertiesType

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

  lazy var instance: Node = self.makeInstance()
  private lazy var pendingStateMutations = [StateMutation]()
  private lazy var pendingStateMutationCallbacks = [StateMutationCallback]()

  public required init(element: Element, children: [Node]? = nil, owner: Node? = nil, context: Context? = nil) {
    self.element = element as! ElementData<PropertiesType>
    self.properties = self.element.properties
    self.owner = owner
    self.context = context
  }

  public func render(_ location: URL) -> Template {
    getContext().templateService.addObserver(observer: self, forLocation: location)

    return getContext().templateService.templates[location]!
  }

  public func updateState(stateMutation: @escaping StateMutation) {
    pendingStateMutations.append(stateMutation)
    enqueueUpdate()
  }

  public func updateState(stateMutation: @escaping (inout StateType) -> Void, completion: @escaping StateMutationCallback) {
    pendingStateMutationCallbacks.append(completion)
    updateState(stateMutation: stateMutation)
  }

  public func build() -> View {
    let isNew = builtView == nil

    let built = instance.build() as! ViewType

    if isNew {
      didBuild()
    } else {
      didUpdate()
    }

    builtView = built

    return built
  }

  public func getBuiltView<V>() -> V? {
    return instance.getBuiltView()
  }

  public func performDiff() {
    let rendered = renderElement()

    if shouldReplace(type: instance.type, with: rendered.type) {
      instance = rendered.build(withOwner: self, context: context)
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
    enqueueUpdate(force: true)
  }

  public func update(with newElement: Element) {
    update(with: newElement, force: nil)
  }

  public func update(with newElement: Element, force: Bool? = nil) {
    let newElement = newElement as! ElementData<PropertiesType>

    let nextProperties = newElement.properties

    willReceiveProperties(nextProperties: nextProperties)

    let nextState = processStateMutations()

    if force ?? self.shouldUpdate(nextProperties: nextProperties, nextState: nextState) {
      willUpdate(nextProperties: nextProperties, nextState: nextState)
      state = nextState
      performUpdate(with: element, nextProperties: nextProperties, shouldUpdate: true)
    } else {
      state = nextState
      properties = nextProperties
    }

    processStateMutationCallbacks()
  }

  public func animate<T>(_ animatable: Animatable<T>, to value: T) {
    animatable.set(value)
    Animator.shared.addAnimatable(animatable)
    Animator.shared.addObserver(self, for: animatable)
  }

  private func processStateMutations() -> StateType {
    var newState = state
    for mutation in pendingStateMutations {
      mutation(&newState)
    }
    pendingStateMutations.removeAll()
    return newState
  }

  private func processStateMutationCallbacks() {
    for callback in pendingStateMutationCallbacks {
      callback()
    }
    pendingStateMutationCallbacks.removeAll()
  }

  private func enqueueUpdate(force: Bool? = nil) {
    // Wait until the start of next run loop to schedule.
    DispatchQueue.main.async {
      self.getContext().updateQueue.async { [weak self] in
        self?.applyUpdate(force: force)
      }
    }
  }

  private func applyUpdate(force: Bool? = nil) {
    guard pendingStateMutations.count > 0 || (force ?? false) else {
      return
    }

    update(with: element, force: force)

    let previousInstance = instance
    let previousParentView = builtView?.parent
    let previousView = builtView

    let layout = root.computeLayout()

    DispatchQueue.main.async {
      if previousInstance !== self.instance {
        // We've changed instances in a component that is nested in another. Just ask the parent to
        // rebuild. This will pick up the new instance and rebuild it.
        if let parent = self.parent {
          _ = parent.build()
        } else if let previousParentView = previousParentView {
          // We don't have a parent because this is a root component. Attempt to silently re-parent the newly built view.
          let view = self.build()
          previousParentView.replace(previousView!, with: view)
        }
      } else {
        _ = self.build()
      }
      layout.apply(to: self.root.getBuiltView()! as ViewType)
    }
  }

  private func renderElement() -> Element {
    return render().build(with: self)
  }

  private func makeInstance() -> Node {
    willBuild()
    if pendingStateMutations.count > 0 {
      state = processStateMutations()
      processStateMutationCallbacks()
    }

    return renderElement().build(withOwner: self, context: nil)
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
  open func willReceiveProperties(nextProperties: PropertiesType) {}
  open func willUpdate(nextProperties: PropertiesType, nextState: StateType) {}
  open func didUpdate() {}
  open func willDetach() {}
}

extension Component: AnimatorObserver {
  public var hashValue: Int {
    return ObjectIdentifier(self as AnyObject).hashValue
  }

  public func didAnimate() {
    let root = self.root
    getContext().updateQueue.async {
      self.update(with: self.element, force: true)
      let layout = root.computeLayout()
      DispatchQueue.main.async {
        _ = self.build()
        layout.apply(to: root.getBuiltView()! as ViewType)
      }
    }
  }

  public func equals(_ other: AnimatorObserver) -> Bool {
    guard let other = other as? Component<StateType, PropertiesType, ViewType> else {
      return false
    }
    return self == other
  }
}

public func ==<StateType: State, PropertiesType: Properties, ViewType: View>(lhs: Component<StateType, PropertiesType, ViewType>, rhs: Component<StateType, PropertiesType, ViewType>) -> Bool {
  return lhs === rhs
}
