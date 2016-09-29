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

open class CompositeComponent<StateType: State, PropertiesType: ViewProperties, ViewType: View>: Component, Model {
  public weak var parent: Node?
  public weak var owner: Node?

  public var element: ElementData<PropertiesType>
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
        _instance =  self.render().build(with: self, context: nil)
      }
      return _instance!
    }
    set {
      _instance = newValue
    }
  }

  public required init(element: Element, children: [Node]? = nil, owner: Node? = nil) {
    self.element = element as! ElementData<PropertiesType>
    self.properties = self.element.properties
    self.owner = owner
  }

  open func render() -> Element {
    fatalError("Must be implemented by subclasses")
  }

  public func render(withLocation location: URL, model: Model? = nil) -> Element {
    getContext().templateService.addObserver(observer: self, forLocation: location)

    return try! getContext().templateService.element(withLocation: location, model: model ?? self)
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

  open func shouldUpdate(nextProperties: PropertiesType, nextState: StateType) -> Bool {
    return properties != nextProperties || state != nextState
  }

  open func getInitialState() -> StateType {
    return StateType()
  }
}
