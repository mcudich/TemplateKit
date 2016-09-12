//
//  CompositeComponent.swift
//  TemplateKit
//
//  Created by Matias Cudich on 9/11/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation

public protocol State {
  init()
}

struct EmptyState: State {}

open class CompositeComponent<StateType: State>: Component {
  public var owner: Component?
  public var element: Element?
  public var instance: Node?
  public var context: Context?
  public lazy var componentState: Any? = self.getInitialState()

  open var properties: [String : Any]

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

  open func getInitialState() -> StateType {
    return StateType()
  }
}
