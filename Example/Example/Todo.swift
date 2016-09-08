//
//  Todo.swift
//  Example
//
//  Created by Matias Cudich on 9/8/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import TemplateKit

class Todo: Node {
  public weak var owner: Node?
  public var currentInstance: BaseNode?
  public var currentElement: Element?
  public var properties: [String : Any]
  public var state: Any? = State()

  struct State {
    var text = "blah"
  }

  private var todoState: State {
    get {
      return state as! State
    }
    set {
      state = newValue
    }
  }

  required init(properties: [String : Any], owner: Node?) {
    self.properties = properties
    self.owner = owner
  }

  func render() -> Element {
    return Element(ElementType.box, ["width": get("width")!], [
      Element(ElementType.text, ["text": todoState.text, "onTap": #selector(Todo.random)]),
    ])
  }

  @objc func random() {
    updateState {
      todoState.text = "\(Int(arc4random()))"
      return todoState
    }
  }
}
