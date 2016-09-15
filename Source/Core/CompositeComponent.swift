//
//  CompositeComponent.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/11/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public struct EmptyState: State, Equatable {
  public init() {}
}

public func ==(lhs: EmptyState, rhs: EmptyState) -> Bool {
  return true
}

open class CompositeComponent<StateType: State where StateType: Equatable>: Component {
  public var owner: Component?
  public var element: Element?
  public var context: Context?
  public lazy var componentState: State = self.getInitialState()

  open var properties: [String : Any]

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

  public var state: StateType {
    set {
      componentState = newValue
    }
    get {
      return componentState as! StateType
    }
  }

  public required init(properties: [String : Any], owner: Component?) {
    self.properties = properties
    self.owner = owner
  }

  open func render() -> Element {
    fatalError("Must be implemented by subclasses")
  }

  public func render(withLocation location: URL, properties: [String: Any]) -> Element {
    return try! getContext().templateService.element(withLocation: location, properties: properties)
  }

  // FIXME: For some reason, implementing this as a default in the Component protocol extension
  // causes subclasses of this class to not receive calls to this function.
  open func shouldUpdate(nextProperties: [String : Any], nextState: State) -> Bool {
    return properties != nextProperties || !componentState.equals(other: nextState)
  }

  public func updateComponentState(stateMutation: @escaping (inout StateType) -> Void) {
    updateState { (state: inout StateType) in
      stateMutation(&state)
    }
  }

  open func getInitialState() -> StateType {
    return StateType()
  }
}
