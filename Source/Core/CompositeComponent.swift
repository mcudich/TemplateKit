//
//  CompositeComponent.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/11/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public struct EmptyState: State {
  public init() {}
}

public func ==(lhs: EmptyState, rhs: EmptyState) -> Bool {
  return true
}

open class CompositeComponent<StateType: State, PropertiesType: Properties, ViewType: View>: Component {
  public weak var parent: Node?
  public weak var owner: Node?

  public var element: Element
  public var builtView: ViewType?
  public var context: Context?
  public lazy var state: StateType = {
    return self.getInitialState()
  }()

  open var properties: PropertiesType

  private var _instance: Node?
  public var instance: Node {
    get {
      if _instance == nil {
        _instance =  self.render().build(with: self)
      }
      return _instance!
    }
    set {
      _instance = newValue
    }
  }

  public required init(element: Element, properties: [String: Any], children: [Node]?, owner: Node?) {
    self.element = element
    self.properties = PropertiesType(properties)
    self.owner = owner
  }

  open func render() -> Element {
    fatalError("Must be implemented by subclasses")
  }

  public func render(withLocation location: URL, properties: [String: Any]) -> Element {
    getContext().templateService.addObserver(observer: self, forLocation: location)

    return try! getContext().templateService.element(withLocation: location, properties: properties)
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

  // FIXME: For some reason, implementing this as a default in the Component protocol extension
  // causes subclasses of this class to not receive calls to this function.
  open func shouldUpdate(nextProperties: PropertiesType, nextState: StateType) -> Bool {
    return properties != nextProperties || state != nextState
  }

  open func getInitialState() -> StateType {
    return StateType()
  }
}
