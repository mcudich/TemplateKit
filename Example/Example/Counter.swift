//
//  App.swift
//  Example
//
//  Created by Matias Cudich on 9/1/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import TemplateKit

class Counter: Node {
  struct State {
    private(set) var counter = 0

    mutating func increment() {
      counter += 1
    }
  }

  var root: Node?
  var renderedView: UIView?
  var properties: [String : Any]
  public var state: Any? = State()
  var calculatedFrame: CGRect?
  public var eventTarget = EventTarget()

  var counterState: State {
    set {
      state = newValue
    }
    get {
      return state as! State
    }
  }

  required init(properties: [String : Any]) {
    self.properties = properties
  }

  func build() -> Node {
    return Box(properties: [:]) {
        [Text(properties: ["text": "Increment", "onTap": incrementCounter]),
         Text(properties: ["text": "\(counterState.counter)"])]
    }
  }

  private func incrementCounter() {
    counterState.increment()
    update()
  }
}
