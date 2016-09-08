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
  public var currentInstance: BaseNode?
  public var currentElement: Element?
  public var properties: [String : Any]
  public var state: Any? = State()

  struct State {
    var counter = 0
    var showCounter = false
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
      getCounter(),
//      Element(ElementType.text, ["text": "\(appState.counter)"]),
      Element(ElementType.node(Details.self), ["message": "\(appState.counter)"])
    ])
  }

  func getCounter() -> Element {
    if appState.showCounter {
      return Element(ElementType.text, ["text": "\(appState.counter)"])
    } else {
      return Element(ElementType.box, [:], [
        Element(ElementType.text, ["text": "not yet"])
      ])
    }
  }

  func incrementCounter() {
    updateState {

        appState.showCounter = !appState.showCounter

      return appState
    }
  }
}
