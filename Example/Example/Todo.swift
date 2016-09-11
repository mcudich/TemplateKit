//
//  Todo.swift
//  Example
//
//  Created by Matias Cudich on 9/8/16.
//  Copyright © 2016 Matias Cudich. All rights reserved.
//

import Foundation
import TemplateKit

class Todo: Component {
  static let location = URL(string: "http://localhost:8000/Todo.xml")!

  public weak var owner: Component?
  public var currentInstance: Node?
  public var currentElement: Element?
  public var properties: [String : Any]
  public var state: Any? = State()
  public var context: Context?

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

  required init(properties: [String : Any], owner: Component?) {
    self.properties = properties
    self.owner = owner
  }

  func render() -> Element {
    let context = getContext()
    return try! context.templateService.element(withLocation: Todo.location, properties: ["todoText": todoState.text])
  }

  @objc func random() {
    updateState {
      todoState.text = "\(Int(arc4random()))"
      return todoState
    }
  }
}
