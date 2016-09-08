//
//  App.swift
//  Example
//
//  Created by Matias Cudich on 8/31/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import TemplateKit

class App: Node {
  public var children: [BaseNode]?
  public var currentInstance: BaseNode?
  public var currentElement: Element?
  public var properties: [String : Any]
  public var state: Any? = State()

  struct State {
    var counter = 0
  }

  private var appState: State {
    get {
      return state as! State
    }
    set {
      state = newValue
    }
  }

  required init(properties: [String : Any]) {
    self.properties = properties
  }

  func render() -> Element {
    return Element(ElementType.box, ["width": CGFloat(320), "height": CGFloat(500), "paddingTop": CGFloat(60)], [
      Element(ElementType.text, ["text": "blah", "onTap": incrementCounter]),
      Element(ElementType.text, ["text": "\(appState.counter)"]),
      Element(ElementType.node(Details.self), ["message": "\(appState.counter)"])
    ])
  }

  func incrementCounter() {
    updateState {
      appState.counter = 3
      return appState
    }
  }
}
